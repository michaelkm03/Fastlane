//
//  ComposerViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ComposerViewController: UIViewController, Composer, ComposerTextViewManagerDelegate, ComposerAttachmentTabBarDelegate, VBackgroundContainer, VPassthroughContainerViewDelegate, VCreationFlowControllerDelegate, HashtagBarControllerSelectionDelegate, HashtagBarViewControllerAnimationDelegate {
    
    private struct Constants {
        static let animationDuration = 0.2
        static let maximumNumberOfTabs = 4
        static let maximumComposerToScreenRatio: CGFloat = 0.2
        static let defaultMaximumTextLength = 0
        static let maximumAttachmentWidthPercentage: CGFloat = 480.0 / 667.0
        static let minimumConfirmButtonContainerHeight: CGFloat = 52
    }
    
    /// ForumEventSender
    var nextSender: ForumEventSender? {
        return delegate
    }
    
    private var visibleKeyboardHeight: CGFloat = 0
    
    /// Referenced so that it can be set toggled between 0 and it's default
    /// height when shouldShowAttachmentContainer is true
    @IBOutlet weak private var attachmentContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var confirmButtonContainerHeightConstraint: NSLayoutConstraint! {
        didSet {
            confirmButtonContainerHeightConstraint.constant = Constants.minimumConfirmButtonContainerHeight
        }
    }
    @IBOutlet weak private var inputViewToBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var textViewContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private(set) var hashtagBarContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var hashtagBarContainerView: UIView!
    
    @IBOutlet weak private var passthroughContainerView: VPassthroughContainerView! {
        didSet {
            passthroughContainerView.delegate = self
        }
    }
    
    @IBOutlet weak private var textView: VPlaceholderTextView!
    
    @IBOutlet weak private var attachmentTabBar: ComposerAttachmentTabBar!
    
    @IBOutlet weak private var attachmentContainerView: UIView!
    @IBOutlet weak private var interactiveContainerView: UIView!
    @IBOutlet weak private var confirmButton: UIButton! {
        didSet {
            confirmButton.layer.cornerRadius = 5
            confirmButton.clipsToBounds = true
        }
    }
    @IBOutlet weak private var confirmButtonContainer: UIView!
    
    private var searchTextChanged = false

    private var selectedAsset: ContentMediaAsset?
    
    private var composerTextViewManager: ComposerTextViewManager?
    private var keyboardManager: VKeyboardNotificationManager?
    
    private var totalComposerHeight: CGFloat {
        guard isViewLoaded() && composerIsVisible else {
            return 0
        }
        return fabs(inputViewToBottomConstraint.constant)
            + textViewContainerHeightConstraint.constant
            + attachmentContainerHeightConstraint.constant
            + hashtagBarContainerHeightConstraint.constant
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
        
        guard let attachmentMenuItems = attachmentMenuItems where isViewLoaded() else {
            return false
        }
        
        if dependencyManager.alwaysShowAttachmentBar == true {
            return true
        }
        
        return !attachmentMenuItems.isEmpty && textViewIsEditing
    }
    
    weak var delegate: ComposerDelegate? {
        didSet {
            setupAttachmentTabBar()
        }
    }
    
    private var userIsOwner: Bool {
        return VCurrentUser.user()?.isCreator?.boolValue ?? false
    }
    
    var dependencyManager: VDependencyManager! {
        didSet {
            setupUserDependentUI()
            updateAppearanceFromDependencyManager()
            creationFlowPresenter = VCreationFlowPresenter(dependencyManager: dependencyManager)
        }
    }
    
    var creationFlowPresenter: VCreationFlowPresenter! {
        didSet {
            creationFlowPresenter.creationFlowControllerDelegate = self
        }
    }
    
    private lazy var showKeyboardBlock: VKeyboardManagerKeyboardChangeBlock = { startFrame, endFrame, animationDuration, animationCurve in
        
        self.updateViewsForNewVisibleKeyboardHeight(endFrame.height, animationOptions: UIViewAnimationOptions(rawValue: UInt(animationCurve.rawValue << 16)), animationDuration: animationDuration)
    }
    
    private lazy var hideKeyboardBlock: VKeyboardManagerKeyboardChangeBlock = { startFrame, endFrame, animationDuration, animationCurve in
        
        self.updateViewsForNewVisibleKeyboardHeight(0, animationOptions: UIViewAnimationOptions(rawValue: UInt(animationCurve.rawValue << 16)), animationDuration: animationDuration)
    }
    
    // MARK: - Composer
    
    var maximumTextInputHeight = CGFloat.max
    
    func showKeyboard() {
        textView.becomeFirstResponder()
    }
    
    func dismissKeyboard(animated: Bool) {
        if textViewIsEditing && textViewCanDismiss {
            if animated {
                textView.resignFirstResponder()
            } else {
                UIView.performWithoutAnimation() {
                    self.textView.resignFirstResponder()
                }
            }
        }
    }
    
    private var composerIsVisible = true
    
    func setComposerVisible(visible: Bool, animated: Bool) {
        guard visible != composerIsVisible else {
            return
        }
        
        if animated {
            UIView.animateWithDuration(0.3) {
                self.setComposerVisible(visible, animated: false)
                self.view.layoutIfNeeded()
            }
        }
        else {
            inputViewToBottomConstraint.constant = visible ? 0.0 : -totalComposerHeight
            composerIsVisible = visible
            delegate?.composer(self, didUpdateContentHeight: totalComposerHeight)
        }
    }
    
    // MARK: - HashtagBar
    
    private var hashtagBarController: HashtagBarController! {
        didSet {
            hashtagBarController.selectionDelegate = self
        }
    }
    
    // MARK: - HashtagBarControllerSearchDelegate
    
    func hashtagBarController(hashtagBarController: HashtagBarController, selectedHashtag hashtag: String) {
        
        guard let (_, range) = textViewCurrentHashtag else {
            return
        }
        
        let replacementText = hashtag + " "
        if composerTextViewManager?.replaceTextInRange(range, withText: replacementText, inTextView: textView) == true {
            hashtagBarController.searchText = nil
        }
    }
    
    // MARK: - HashtagBarControllerAnimationDelegate
    
    func hashtagBarViewController(hashtagBarViewController: HashtagBarViewController, isUpdatingConstraints updateBlock: Void -> ()) {
        updateBlock()
        searchTextChanged = true
        view.setNeedsUpdateConstraints()
    }
    
    // MARK: - ComposerTextViewManagerDelegate
    
    var textViewHasText: Bool = false {
        didSet {
            confirmButton.enabled = textViewHasText || selectedAsset != nil
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
    
    var textViewIsEditing: Bool = false {
        didSet {
            if oldValue != textViewIsEditing {
                view.setNeedsUpdateConstraints()
            }
        }
    }
    
    var textViewHasPrependedImage: Bool = false {
        didSet {
            if oldValue != textViewHasPrependedImage {
                attachmentTabBar.buttonsEnabled = !textViewHasPrependedImage
            }
        }
    }
    
    var textViewCanDismiss: Bool {
        return interactiveContainerView.layer.animationKeys() == nil
    }
    
    var textViewCurrentHashtag: (String, NSRange)? {
        didSet {
            guard let (hashtag, _) = textViewCurrentHashtag else {
                hashtagBarController.searchText = nil
                return
            }
            if let (oldHashtag, _) = oldValue {
                if hashtag != oldHashtag {
                    hashtagBarController.searchText = hashtag
                }
            } else {
                hashtagBarController.searchText = hashtag
            }
        }
    }
    
    func textViewDidHitCharacterLimit(textView: UITextView) {
        textView.v_performShakeAnimation()
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userChanged), name: kLoggedInChangedNotification, object: nil)
        setupUserDependentUI()
        
        //Setup once-initialized properties that cannot be created on initialization
        keyboardManager = VKeyboardNotificationManager(keyboardWillShowBlock: showKeyboardBlock, willHideBlock: hideKeyboardBlock, willChangeFrameBlock: showKeyboardBlock)
        
        maximumTextInputHeight = view.bounds.height * Constants.maximumComposerToScreenRatio
        
        //Setup and style views
        setupAttachmentTabBar()
        setupTextView()
        updateAppearanceFromDependencyManager()
        composerTextViewManager = ComposerTextViewManager(textView: textView, delegate: self, maximumTextLength: maximumTextLength)
        setupHashtagBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.composer(self, didUpdateContentHeight: totalComposerHeight)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
    }

    private func updateViewsForNewVisibleKeyboardHeight(visibleKeyboardHeight: CGFloat, animationOptions: UIViewAnimationOptions, animationDuration: Double) {
        guard self.visibleKeyboardHeight != visibleKeyboardHeight else {
            return
        }
        self.visibleKeyboardHeight = visibleKeyboardHeight
        updateViewConstraints()
        if animationDuration != 0 {
            UIView.animateWithDuration(animationDuration, delay: 0, options: animationOptions, animations: {
                self.inputViewToBottomConstraint.constant = visibleKeyboardHeight
                self.delegate?.composer(self, didUpdateContentHeight: self.totalComposerHeight)
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            inputViewToBottomConstraint.constant = visibleKeyboardHeight
            self.view.setNeedsLayout()
            self.delegate?.composer(self, didUpdateContentHeight: self.totalComposerHeight)
        }
    }
    
    override func updateViewConstraints() {

        let desiredAttachmentContainerHeight = shouldShowAttachmentContainer ? confirmButtonContainer.bounds.height : 0
        let attachmentContainerHeightNeedsUpdate = attachmentContainerHeightConstraint.constant != desiredAttachmentContainerHeight
        if attachmentContainerHeightNeedsUpdate {
            self.attachmentContainerHeightConstraint.constant = desiredAttachmentContainerHeight
        }
        
        var textViewContentHeight = textView.calculatePlaceholderTextHeight()
        var textViewContainerHeight = textViewContentHeight
        if textViewHasText {
            textViewContentHeight = ceil(textView.contentSize.height)
            //Ensure that text view container is less than maximum height
            textViewContainerHeight = min(textViewContentHeight, maximumTextInputHeight)
        }
        
        //Ensure text view container is at least as tall as the confirm button container
        textViewContainerHeight = max(textViewContainerHeight, confirmButtonContainerHeightConstraint.constant)
        
        let textViewContainerHeightNeedsUpdate = textViewContainerHeightConstraint.constant != textViewContainerHeight
        if textViewContainerHeightNeedsUpdate {
            textViewContainerHeightConstraint.constant = textViewContainerHeight
        }
        
        let textViewHeightNeedsUpdate = textViewHeightConstraint.constant != textViewContentHeight
        if textViewHeightNeedsUpdate {
            textViewHeightConstraint.constant = textViewContentHeight
        }
        
        guard attachmentContainerHeightNeedsUpdate ||
            textViewContainerHeightNeedsUpdate ||
            textViewHeightNeedsUpdate ||
            searchTextChanged else {
            // No reason to lay out views again
            super.updateViewConstraints()
            return
        }
        
        searchTextChanged = false
        
        let previousContentOffset = textView.contentOffset
        UIView.animateWithDuration(Constants.animationDuration, delay: 0, options: .AllowUserInteraction, animations: {
            self.delegate?.composer(self, didUpdateContentHeight: self.totalComposerHeight)
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
    
    @objc private func setupUserDependentUI() {
        let isOwner = userIsOwner
        maximumTextLength = dependencyManager.maximumTextLengthForOwner(isOwner)
        attachmentMenuItems = dependencyManager.attachmentMenuItemsForOwner(isOwner)
    }
    
    private func setupTextView() {
        textView.text = nil
        textView.lineFragmentPadding = 0
        textView.placeholderText = dependencyManager.inputPromptText
    }
    
    private func setupAttachmentTabBar() {
        if isViewLoaded() {
            attachmentTabBar.setupWithAttachmentMenuItems(
                attachmentMenuItems,
                maxNumberOfMenuItems: Constants.maximumNumberOfTabs
            )
            attachmentTabBar.delegate = self
        }
    }
    
    private func setupHashtagBar() {
        let hashtagBarViewController = HashtagBarViewController.new(dependencyManager, containerHeightConstraint: hashtagBarContainerHeightConstraint)
        addChildViewController(hashtagBarViewController)
        hashtagBarContainerView.addSubview(hashtagBarViewController.view)
        hashtagBarContainerView.v_addFitToParentConstraintsToSubview(hashtagBarViewController.view)
        hashtagBarViewController.animationDelegate = self
        hashtagBarController = hashtagBarViewController.hashtagBarController
    }

    private func updateAppearanceFromDependencyManager() {
        guard isViewLoaded() else {
            return
        }
        
        textView.font = dependencyManager.inputTextFont
        textView.setPlaceholderFont(dependencyManager.inputTextFont)
        textView.textColor = dependencyManager.inputTextColor
        textView.setPlaceholderTextColor(dependencyManager.inputPlaceholderTextColor)
        textView.keyboardAppearance = dependencyManager.keyboardAppearance
        confirmButton.setTitleColor(dependencyManager.confirmButtonDeselectedTextColor, forState: .Normal)
        confirmButton.setTitleColor(dependencyManager.confirmButtonSelectedTextColor, forState: .Selected)
        confirmButton.titleLabel?.font = dependencyManager.confirmButtonTextFont
        confirmButton.backgroundColor = dependencyManager.confirmButtonBackgroundColor
        attachmentTabBar.tabItemDeselectedTintColor = dependencyManager.tabItemDeselectedTintColor
        attachmentTabBar.tabItemSelectedTintColor = dependencyManager.tabItemSelectedTintColor
        confirmButton.setTitle(dependencyManager.confirmKeyText, forState: .Normal)
        dependencyManager.addBackgroundToBackgroundHost(self)
        
        view.layoutIfNeeded()
    }
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return interactiveContainerView
    }
    
    // MARK: - ComposerAttachmentTabBarDelegate
    
    func composerAttachmentTabBar(composerAttachmentTabBar: ComposerAttachmentTabBar, didSelectNagiationItem navigationItem: VNavigationMenuItem) {
        let identifier = navigationItem.identifier
        let creationFlowType = CreationFlowTypeHelper.creationFlowTypeForIdentifier(identifier)
        if creationFlowType != .Unknown {
            delegate?.composer(self, didSelectCreationFlowType: creationFlowType)
        } else if let composerInputAttachmentType = ComposerInputAttachmentType(rawValue: identifier) where composerInputAttachmentType == .Hashtag {
            composerTextViewManager?.appendTextIfPossible(textView, text: "#")
        }
    }
    
    // MARK: - VCreationFlowControllerDelegate
    
    func creationFlowController(creationFlowController: VCreationFlowController!, finishedWithPreviewImage previewImage: UIImage!, capturedMediaURL: NSURL!) {
        guard let contentType = contentType(for: creationFlowController) else {
            creationFlowController.v_showErrorDefaultError()
            return
        }
        
        var preview = previewImage
        if contentType == .gif,
            let image = capturedMediaURL.v_videoPreviewImage {
            
            preview = image
        }
        
        selectedAsset = ContentMediaAsset(contentType: contentType, url: capturedMediaURL)
        let maxDimension = view.bounds.width * Constants.maximumAttachmentWidthPercentage
        let resizedImage = preview.scaledImageWithMaxDimension(maxDimension, upScaling: true)
        composerTextViewManager?.prependImage(resizedImage, toTextView: textView)
        self.dismissViewControllerAnimated(true) { [weak self] _ in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.view.setNeedsUpdateConstraints()
            let textView = strongSelf.textView
            textView.becomeFirstResponder()
            textView.selectedRange = NSMakeRange(textView.text.characters.count, 0)
        }
    }
    
    private func contentType(for creationFlowController: VCreationFlowController!) -> ContentType? {
        switch creationFlowController.mediaType() {
        case .Image:
            return .image
        case .Video:
            if creationFlowController.dynamicType == VGIFCreationFlowController.self {
                return .gif
            } else {
                return .video
            }
        case .Unknown:
            assertionFailure("Creation flow controller returned an invalid media type.")
            return nil
        }
    }
    
    func shouldShowPublishScreenForFlowController() -> Bool {
        return false
    }
    
    func creationFlowControllerDidCancel(creationFlowController: VCreationFlowController!) {
        creationFlowPresenter.dismissCurrentFlowController()
    }
    
    // MARK: - VPassthroughContainerViewDelegate
    
    func passthroughViewRecievedTouch(passthroughContainerView: VPassthroughContainerView!) {
        dismissKeyboard(true)
    }
    
    // MARK: - Actions
    
    @IBAction func pressedConfirmButton() {
        if let asset = selectedAsset {
            sendMessage(asset: asset, text: textView.text)
        } else {
            sendMessage(text: textView.text)
        }
        composerTextViewManager?.resetTextView(textView)
        selectedAsset = nil
    }
    
    // MARK: - Notification response
    
    func userChanged() {
        guard let user = VCurrentUser.user() else {
            KVOController.unobserveAll()
            return
        }
        
        KVOController.observe(user, keyPath: "isCreator", options: [.New, .Initial], action: #selector(setupUserDependentUI))
    }
}

// Update this extension to parse real values once they're returned in template
private extension VDependencyManager {
    
    func maximumTextLengthForOwner(owner: Bool) -> Int {
        return owner ? 0 : numberForKey("maximumTextLength").integerValue
    }
    
    var inputPromptText: String {
        return stringForKey("inputTextPrompt") ?? NSLocalizedString("What do you think?", comment: "")
    }
    
    func attachmentMenuItemsForOwner(owner: Bool) -> [VNavigationMenuItem]? {
        let menuItemKey = owner ? "creatorItems" : "userItems"
        return menuItemsForKey(menuItemKey)
    }
    
    var inputTextColor: UIColor? {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
    
    var inputPlaceholderTextColor: UIColor? {
        return colorForKey(VDependencyManagerPlaceholderTextColorKey)
    }
    
    var confirmButtonDeselectedTextColor: UIColor? {
        return colorForKey("color.link.deselected")
    }
    
    var confirmButtonSelectedTextColor: UIColor? {
        return colorForKey("color.link.selected")
    }
    
    var confirmButtonBackgroundColor: UIColor? {
        return colorForKey(VDependencyManagerAccentColorKey)
    }
    
    var inputTextFont: UIFont? {
        return fontForKey(VDependencyManagerParagraphFontKey)
    }

    var confirmButtonTextFont: UIFont? {
        return fontForKey(VDependencyManagerLabel4FontKey)
    }
    
    var tabItemDeselectedTintColor: UIColor? {
        return colorForKey("color.link.deselected")
    }
    
    var tabItemSelectedTintColor: UIColor? {
        return colorForKey("color.link.selected")
    }
    
    var alwaysShowAttachmentBar: Bool? {
        return numberForKey("alwaysShowAttachmentBar")?.boolValue
    }
    
    var keyboardAppearance: UIKeyboardAppearance {
        return keyboardStyleForKey("keyboardStyle") ?? .Light
    }
    
    var confirmKeyText: String {
        return stringForKey("confirmKeyText") ?? NSLocalizedString("Send", comment: "")
    }
}
