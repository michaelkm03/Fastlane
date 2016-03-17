//
//  ComposerViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ComposerViewController: UIViewController, Composer, ComposerTextViewManagerDelegate, VBackgroundContainer {
    
    private struct Constants {
        
        static let animationDuration = 0.2
        static let minimumTextViewHeight: CGFloat = 34
        static let maximumNumberOfTabs = 4
    }
    
    @IBOutlet private var inputViewToBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private var textViewHeightConstraint: NSLayoutConstraint!
    
    /// Referenced so that it can be set toggled between 0 and it's default
    /// height when shouldShowAttachmentContainer is true
    @IBOutlet private var attachmentContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private var textView: VPlaceholderTextView!
    
    @IBOutlet private var attachmentTabBar: ComposerAttachmentTabBar!
    
    @IBOutlet private var attachmentContainerView: UIView!
    
    @IBOutlet private var interactiveContainerView: UIView!
    
    private var composerTextViewManager: ComposerTextViewManager?
    
    private var keyboardManager: VKeyboardNotificationManager?
    
    private var visibleKeyboardHeight: CGFloat = 0
    
    private var totalComposerHeight: CGFloat {
        return isViewLoaded() ? fabs(inputViewToBottomConstraint.constant) + textViewHeightConstraint.constant : 0
    }
    
    /// The maximum number of characters a user can input into
    /// the composer. Defaults to 0, allowing users to input as
    /// much text as they like.
    private var maximumTextLength = DefaultPropertyValues.maximumTextLength {
        didSet {
            composerTextViewManager?.maximumTextLength = maximumTextLength
        }
    }
    
    /// The attachment tabs displayed by the composer. Updating this variable
    /// triggers a UI update. Defaults to nil.
    private var attachmentMenuItems: [VNavigationMenuItem]? = nil {
        didSet {
            setupAttachmentTabBar()
        }
    }
    
    private var shouldShowAttachmentContainer: Bool {
        return attachmentMenuItems != nil || textViewHasText
    }
    
    weak var delegate: ComposerDelegate? {
        didSet {
            setupAttachmentTabBar()
        }
    }
    
    var dependencyManager: VDependencyManager! {
        didSet {
            maximumTextLength = dependencyManager.maximumTextLength()
            let userIsOwner = VCurrentUser.user()?.isCreator.boolValue ?? false
            attachmentMenuItems = dependencyManager.attachmentMenuItemsForOwner(userIsOwner)
            updateBackground()
        }
    }
    
    private lazy var updateHeightBlock: VKeyboardManagerKeyboardChangeBlock = { startFrame, endFrame, animationDuration, animationCurve in
        
        self.updateViewsForNewVisibleKeyboardHeight(endFrame.height, animationOptions: UIViewAnimationOptions(rawValue: UInt(animationCurve.rawValue << 16)), animationDuration: animationDuration)
    }
    
    private lazy var hideKeyboardBlock: VKeyboardManagerKeyboardChangeBlock = { startFrame, endFrame, animationDuration, animationCurve in
        
        self.updateViewsForNewVisibleKeyboardHeight(0, animationOptions: UIViewAnimationOptions(rawValue: UInt(animationCurve.rawValue << 16)), animationDuration: animationDuration)
    }
    
    // MARK: - ComposerController
    
    var maximumTextInputHeight = DefaultPropertyValues.maximumTextInputHeight
    
    // MARK: - ComposerTextViewManagerDelegate
    
    var textViewHasText: Bool = false {
        didSet {
            if oldValue != textViewHasText {
                view.setNeedsUpdateConstraints()
            }
        }
    }
    
    var textViewContentSize: CGSize = CGSize.zero {
        didSet {
            if oldValue != textViewContentSize {
                view.setNeedsUpdateConstraints()
            }
        }
    }
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return interactiveContainerView
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardManager = VKeyboardNotificationManager(keyboardWillShowBlock: updateHeightBlock, willHideBlock: hideKeyboardBlock, willChangeFrameBlock: updateHeightBlock)
        
        composerTextViewManager = ComposerTextViewManager(textView: textView, delegate: self, maximumTextLength: maximumTextLength)
        
        setupAttachmentTabBar()
        setupTextView()
        updateBackground()
    }
    
    private func updateViewsForNewVisibleKeyboardHeight(visibleKeyboardHeight: CGFloat, animationOptions: UIViewAnimationOptions, animationDuration: Double) {
        
        self.visibleKeyboardHeight = visibleKeyboardHeight
        inputViewToBottomConstraint.constant = visibleKeyboardHeight
        delegate?.composer(self, didUpdateToContentHeight: totalComposerHeight)
        UIView.animateWithDuration(animationDuration, delay: 0, options: animationOptions, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func updateViewConstraints() {

        let desiredAttachmentContainerHeight = shouldShowAttachmentContainer ? DefaultPropertyValues.attachmentContainerHeight : 0
        let attachmentContainerHeightNeedsUpdate = attachmentContainerHeightConstraint.constant != desiredAttachmentContainerHeight
        if attachmentContainerHeightNeedsUpdate {
            self.attachmentContainerHeightConstraint.constant = desiredAttachmentContainerHeight
        }
        
        let textHeight = min(ceil(self.textView.contentSize.height), self.maximumTextInputHeight)
        let desiredTextViewHeight = self.textViewHasText ? max(textHeight, Constants.minimumTextViewHeight) : Constants.minimumTextViewHeight
        let textViewHeightNeedsUpdate = self.textViewHeightConstraint.constant != desiredTextViewHeight
        if textViewHeightNeedsUpdate {
            self.textViewHeightConstraint.constant = desiredTextViewHeight
        }
        
        guard attachmentContainerHeightNeedsUpdate || textViewHeightNeedsUpdate else {
            // No reason to lay out views again
            super.updateViewConstraints()
            return
        }
        
        delegate?.composer(self, didUpdateToContentHeight: totalComposerHeight)
        
        let previousContentOffset = self.textView.contentOffset
        UIView.animateWithDuration(Constants.animationDuration, delay: 0, options: .AllowUserInteraction, animations: {
            self.textView.layoutIfNeeded()
            if textViewHeightNeedsUpdate {
                self.textView.setContentOffset(previousContentOffset, animated: true)
            }
            self.attachmentContainerView.layoutIfNeeded()
            self.interactiveContainerView.layoutIfNeeded()
        }, completion: nil)
        
        super.updateViewConstraints()
    }
    
    // MARK: - Subview setup
    
    private func setupTextView() {
        textView.text = nil
        textView.textContainer.heightTracksTextView = true
        textView.placeholderText = NSLocalizedString("What do you think...", comment: "")
    }
    
    private func setupAttachmentTabBar() {
        if isViewLoaded() {
            attachmentTabBar.setupWithAttachmentMenuItems(attachmentMenuItems, maxNumberOfMenuItems: Constants.maximumNumberOfTabs)
            attachmentTabBar.delegate = delegate
        }
    }
    
    private func updateBackground() {
        if isViewLoaded() {
            dependencyManager?.addBackgroundToBackgroundHost(self)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func pressedConfirmButton() {
        // Call appropriate delegate methods based on caption / media in composer
        composerTextViewManager?.resetTextView(textView)
    }
}

private struct DefaultPropertyValues {
    
    static let maximumTextInputHeight = CGFloat.max
    static let maximumTextLength = 0
    static let attachmentContainerHeight: CGFloat = 52
}

// Update this extension to parse real values once they're returned in template
private extension VDependencyManager {
    
    func maximumTextLength() -> Int {
        return DefaultPropertyValues.maximumTextLength
    }
    
    func attachmentMenuItemsForOwner(owner: Bool) -> [VNavigationMenuItem]? {
        let menuItemKey = owner ? "ownerItems" : VDependencyManagerMenuItemsKey
        return menuItemsForKey(menuItemKey) as? [VNavigationMenuItem]
    }
}
