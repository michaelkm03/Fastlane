//
//  ComposerViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ComposerViewController: UIViewController, Composer, ComposerTextViewManagerDelegate, VBackgroundContainer {
    
    private let animationDuration = 0.3
    
    private let minimumTextViewHeight: CGFloat = 32
    
    private lazy var updateHeightBlock: VKeyboardManagerKeyboardChangeBlock = { startFrame, endFrame, animationDuration, animationCurve in
        
        let keyboardHeight = endFrame.height
        self.keyboardHeight = keyboardHeight
        
        let animationOptions = UIViewAnimationOptions(rawValue: UInt(animationCurve.rawValue << 16))
        self.inputViewToBottomConstraint.constant = keyboardHeight
        self.delegate?.composer(self, didUpdateToContentHeight: self.totalComposerHeight)
        UIView.animateWithDuration(self.animationDuration, delay: 0, options: animationOptions, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
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
    
    private var keyboardHeight: CGFloat = 0
    
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
    private var attachmentTabs: [ComposerAttachmentTab]? = nil {
        didSet {
            if isViewLoaded() {
                attachmentTabBar.setupWithAttachmentTabs(attachmentTabs, maxNumberOfTabs: 4)
            }
        }
    }
    
    private var shouldShowAttachmentContainer: Bool {
        return attachmentTabs != nil || textViewHasText
    }
    
    weak var delegate: ComposerDelegate?
    
    var dependencyManager: VDependencyManager! {
        didSet {
            maximumTextLength = dependencyManager.maximumTextLength()
            attachmentTabs = dependencyManager.attachmentTabs()
            if isViewLoaded() {
                dependencyManager?.addBackgroundToBackgroundHost(self)
            }
        }
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
        
        keyboardManager = VKeyboardNotificationManager(keyboardWillShowBlock: updateHeightBlock, willHideBlock: updateHeightBlock, willChangeFrameBlock: updateHeightBlock)
        
        composerTextViewManager = ComposerTextViewManager(textView: textView, delegate: self, maximumTextLength: maximumTextLength)
        
        attachmentTabBar.setupWithAttachmentTabs(attachmentTabs, maxNumberOfTabs: 1)
        
        setupTextView()
        
        dependencyManager?.addBackgroundToBackgroundHost(self)
    }
    
    override func updateViewConstraints() {

        let desiredAttachmentContainerHeight = shouldShowAttachmentContainer ? DefaultPropertyValues.attachmentContainerHeight : 0
        let attachmentContainerHeightNeedsUpdate = attachmentContainerHeightConstraint.constant != desiredAttachmentContainerHeight
        if attachmentContainerHeightNeedsUpdate {
            self.attachmentContainerHeightConstraint.constant = desiredAttachmentContainerHeight
        }
        
        let textHeight = min(ceil(self.textView.contentSize.height), self.maximumTextInputHeight)
        let desiredTextViewHeight = self.textViewHasText ? max(textHeight, minimumTextViewHeight) : minimumTextViewHeight
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
        UIView.animateWithDuration(animationDuration, delay: 0, options: .AllowUserInteraction, animations: {
            self.textView.layoutIfNeeded()
            if textViewHeightNeedsUpdate {
                self.textView.setContentOffset(previousContentOffset, animated: true)
            }
            self.attachmentContainerView.layoutIfNeeded()
            self.interactiveContainerView.layoutIfNeeded()
        }, completion: nil)
        
        super.updateViewConstraints()
    }
    
    private func setupTextView() {
        textView.text = nil
        textView.placeholderText = NSLocalizedString("What do you think...", comment: "")
    }
    
    // MARK: - Actions
    
    @IBAction func pressedConfirmButton() {
        // Call appropriate delegate methods based on caption / media in composer
        textView.resignFirstResponder()
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
    
    func attachmentTabs() -> [ComposerAttachmentTab]? {
        return [ComposerAttachmentTab.Camera]
    }
}
