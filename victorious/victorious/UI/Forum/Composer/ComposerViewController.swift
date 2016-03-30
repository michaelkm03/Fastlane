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
        static let maximumNumberOfTabs = 4
        static let defaultMaximumTextInputHeight = CGFloat.max
        static let defaultMaximumTextLength = 0
        static let defaultAttachmentContainerHeight: CGFloat = 52
    }
    
    private var visibleKeyboardHeight: CGFloat = 0
    
    /// Referenced so that it can be set toggled between 0 and it's default
    /// height when shouldShowAttachmentContainer is true
    @IBOutlet private var attachmentContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var inputViewToBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var textViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private var textView: VPlaceholderTextView!
    @IBOutlet private var singleLineLabel: UILabel!
    
    @IBOutlet private var attachmentTabBar: ComposerAttachmentTabBar!
    
    @IBOutlet private var attachmentContainerView: UIView!
    @IBOutlet private var interactiveContainerView: UIView!
    
    @IBOutlet private var confirmButton: UIButton!
    
    private var composerTextViewManager: ComposerTextViewManager?
    private var keyboardManager: VKeyboardNotificationManager?
    
    private var totalComposerHeight: CGFloat {
        guard isViewLoaded() else {
            return 0
        }
        return fabs(inputViewToBottomConstraint.constant)
            + textViewHeightConstraint.constant
            + attachmentContainerHeightConstraint.constant 
    }
    
    /// The maximum number of characters a user can input into
    /// the composer. Defaults to 0, allowing users to input as
    /// much text as they like.
    private var maximumTextLength = Constants.defaultMaximumTextLength {
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
        guard isViewLoaded() else {
            return false
        }
        
        if dependencyManager.collapseOnKeyboardDismissal {
            return self.visibleKeyboardHeight != 0
        }
        return attachmentMenuItems != nil || textViewHasText
    }
    
    weak var delegate: ComposerDelegate? {
        didSet {
            setupAttachmentTabBar()
        }
    }
    
    private var userIsOwner: Bool {
        return VCurrentUser.user()?.isCreator.boolValue ?? false
    }
    
    var dependencyManager: VDependencyManager! {
        didSet {
            maximumTextLength = dependencyManager.maximumTextLengthForOwner(userIsOwner)
            attachmentMenuItems = dependencyManager.attachmentMenuItemsForOwner(userIsOwner)
            updateAppearanceFromDependencyManager()
        }
    }
    
    private lazy var updateHeightBlock: VKeyboardManagerKeyboardChangeBlock = { startFrame, endFrame, animationDuration, animationCurve in
        
        self.updateViewsForNewVisibleKeyboardHeight(endFrame.height, animationOptions: UIViewAnimationOptions(rawValue: UInt(animationCurve.rawValue << 16)), animationDuration: animationDuration)
    }
    
    private lazy var hideKeyboardBlock: VKeyboardManagerKeyboardChangeBlock = { startFrame, endFrame, animationDuration, animationCurve in
        
        self.updateViewsForNewVisibleKeyboardHeight(0, animationOptions: UIViewAnimationOptions(rawValue: UInt(animationCurve.rawValue << 16)), animationDuration: animationDuration)
    }
    
    // MARK: - Composer
    
    var maximumTextInputHeight = Constants.defaultMaximumTextInputHeight
    
    func dismissKeyboard(animated: Bool) {
        textView.resignFirstResponder()
    }
    
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
        setupSingleLineLabel()
        updateLabelVisibility()
        updateAppearanceFromDependencyManager()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.composer(self, didUpdateToContentHeight: totalComposerHeight)
    }
    
    private func updateViewsForNewVisibleKeyboardHeight(visibleKeyboardHeight: CGFloat, animationOptions: UIViewAnimationOptions, animationDuration: Double) {
        guard self.visibleKeyboardHeight != visibleKeyboardHeight else {
            return
        }
        self.visibleKeyboardHeight = visibleKeyboardHeight
        inputViewToBottomConstraint.constant = visibleKeyboardHeight
        updateViewConstraints()
        updateLabelVisibility()
        if animationDuration != 0 {
            UIView.animateWithDuration(animationDuration, delay: 0, options: animationOptions, animations: {
                self.delegate?.composer(self, didUpdateToContentHeight: self.totalComposerHeight)
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            self.view.setNeedsLayout()
        }
    }
    
    private func updateLabelVisibility() {
        
        let shouldCollapseToOneLine = dependencyManager.collapseOnKeyboardDismissal && visibleKeyboardHeight == 0
        let showLabel = shouldCollapseToOneLine && textViewHasText
        textView.hidden = showLabel
        singleLineLabel.hidden = !showLabel
        singleLineLabel.text = textView.text
    }
    
    override func updateViewConstraints() {

        let desiredAttachmentContainerHeight = shouldShowAttachmentContainer ? Constants.defaultAttachmentContainerHeight : 0
        let attachmentContainerHeightNeedsUpdate = attachmentContainerHeightConstraint.constant != desiredAttachmentContainerHeight
        if attachmentContainerHeightNeedsUpdate {
            self.attachmentContainerHeightConstraint.constant = desiredAttachmentContainerHeight
        }
        
        var desiredTextViewHeight = textView.placeholderTextHeight
        let shouldCollapseToOneLine = dependencyManager.collapseOnKeyboardDismissal && visibleKeyboardHeight == 0
        if !shouldCollapseToOneLine && textViewHasText {
            let textHeight = min(ceil(textView.contentSize.height), maximumTextInputHeight)
            desiredTextViewHeight = max(textHeight, desiredTextViewHeight)
        }
        
        let textViewHeightNeedsUpdate = textViewHeightConstraint.constant != desiredTextViewHeight
        if textViewHeightNeedsUpdate {
            self.textViewHeightConstraint.constant = desiredTextViewHeight
        }
        
        guard attachmentContainerHeightNeedsUpdate || textViewHeightNeedsUpdate else {
            // No reason to lay out views again
            super.updateViewConstraints()
            return
        }
        
        let previousContentOffset = textView.contentOffset
        UIView.animateWithDuration(Constants.animationDuration, delay: 0, options: .AllowUserInteraction, animations: {
            self.delegate?.composer(self, didUpdateToContentHeight: self.totalComposerHeight)
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
        textView.lineFragmentPadding = 0
        textView.placeholderText = dependencyManager.inputPromptText
    }
    
    private func setupSingleLineLabel() {
        singleLineLabel.text = nil
        singleLineLabel.numberOfLines = 1
        singleLineLabel.lineBreakMode = .ByTruncatingTail
        singleLineLabel.backgroundColor = UIColor.clearColor()
    }
    
    private func setupAttachmentTabBar() {
        if isViewLoaded() {
            attachmentTabBar.setupWithAttachmentMenuItems(attachmentMenuItems, maxNumberOfMenuItems: Constants.maximumNumberOfTabs)
            attachmentTabBar.delegate = self
        }
    }
    
    private func updateAppearanceFromDependencyManager() {
        guard isViewLoaded() else {
            return
        }
        
        dependencyManager.addBackgroundToBackgroundHost(self)
        textView.font = dependencyManager.inputTextFont
        textView.setPlaceholderFont(dependencyManager.inputTextFont)
        singleLineLabel.font = dependencyManager.inputTextFont
        textView.textColor = dependencyManager.inputTextColor
        textView.setPlaceholderTextColor(dependencyManager.inputPlaceholderTextColor)
        singleLineLabel.textColor = dependencyManager.inputTextColor
        textView.keyboardAppearance = dependencyManager.keyboardAppearance
        confirmButton.setTitleColor(dependencyManager.confirmButtonTextColor, forState: .Normal)
        confirmButton.titleLabel?.font = dependencyManager.confirmButtonTextFont
        attachmentTabBar.tabItemTintColor = dependencyManager.tabItemTintColor
        confirmButton.setTitle(dependencyManager.confirmKeyText, forState: .Normal)
    }
    
    // MARK: - ComposerAttachmentTabBarDelegate
    
    func composerAttachmentTabBar(composerAttachmentTabBar: ComposerAttachmentTabBar, selectedNavigationItem navigationItem: VNavigationMenuItem) {
        let identifier = navigationItem.identifier
        let creationType = CreationTypeHelper.creationTypeForIdentifier(identifier)
        if creationType != .Unknown {
            delegate?.composer(self, selectedCreationType: creationType)
        } else if let composerInputAttachmentType = ComposerInputAttachmentType(rawValue: identifier) {
            switch composerInputAttachmentType {
            case .Hashtag:
                composerTextViewManager?.appendTextIfPossible(textView, text: "#")
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func pressedConfirmButton() {
        // Call appropriate delegate methods based on caption / media in composer
        composerTextViewManager?.resetTextView(textView)
    }
    
    @IBAction func touchedInputArea() {
        textView.becomeFirstResponder()
        updateLabelVisibility()
    }
}

// Update this extension to parse real values once they're returned in template
private extension VDependencyManager {
    
    func maximumTextLengthForOwner(owner: Bool) -> Int {
        return owner ? 0 : numberForKey("maximumTextLength").integerValue
    }
    
    var inputPromptText: String {
        return stringForKey("inputPromptText")
    }
    
    func attachmentMenuItemsForOwner(owner: Bool) -> [VNavigationMenuItem]? {
        let menuItemKey = owner ? "ownerItems" : VDependencyManagerMenuItemsKey
        return menuItemsForKey(menuItemKey)
    }
    
    var inputTextColor: UIColor {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
    
    var inputPlaceholderTextColor: UIColor {
        return colorForKey(VDependencyManagerPlaceholderTextColorKey)
    }
    
    var confirmButtonTextColor: UIColor {
        return colorForKey(VDependencyManagerAccentColorKey)
    }
    
    var inputTextFont: UIFont {
        return fontForKey(VDependencyManagerParagraphFontKey)
    }
    
    var confirmButtonTextFont: UIFont {
        return fontForKey(VDependencyManagerLabel4FontKey)
    }
    
    var tabItemTintColor: UIColor {
        return colorForKey(VDependencyManagerLinkColorKey)
    }
    
    var collapseOnKeyboardDismissal: Bool {
        return numberForKey("collapseOnKeyboardDismissal").boolValue
    }
    
    var keyboardAppearance: UIKeyboardAppearance {
        return keyboardStyleForKey("keyboardStyle")
    }
    
    var confirmKeyText: String {
        return stringForKey("confirmKeyText")
    }
}
