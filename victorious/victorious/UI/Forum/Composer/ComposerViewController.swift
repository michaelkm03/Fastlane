//
//  ComposerViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK
import FLAnimatedImage

/// Handles view manipulation and message sending related to the composer. Could definitely use a refactor to make it less stateful.
class ComposerViewController: UIViewController, Composer, ComposerTextViewManagerDelegate, ComposerAttachmentTabBarDelegate, VBackgroundContainer, VCreationFlowControllerDelegate, HashtagBarControllerSelectionDelegate, HashtagBarViewControllerAnimationDelegate, VPassthroughContainerViewDelegate, PastableTextViewDelegate, ToggleableImageButtonDelegate {
    private struct Constants {
        static let animationDuration = 0.2
        static let maximumNumberOfTabs = 4
        static let maximumComposerToScreenRatio: CGFloat = 0.2
        static let defaultMaximumTextLength = 0
        static let maximumAttachmentWidthPercentage: CGFloat = 480.0 / 667.0
        static let minimumConfirmButtonContainerHeight: CGFloat = 52
        static let composerTextInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        static let confirmButtonHorizontalInset: CGFloat = 16
        static let stickerInputAreaHeight: CGFloat = 120
        static let gifInputAreaHeight: CGFloat = 90
        static let vipLockComposerMargin: CGFloat = 8
        static let gifType = "gif"
    }
    
    // MARK: - ForumEventSender
    
    var nextSender: ForumEventSender? {
        return delegate
    }
    
    private var visibleKeyboardHeight: CGFloat = 0
    
    private var customInputAreaState: CustomInputAreaState = .hidden
    
    private var customInputAreaHeight: CGFloat = 0
    
    @IBOutlet private var customInputViewContainer: UIView!
    
    private var customInputViewControllerIsAppearing = false {
        didSet {
            if oldValue != customInputViewControllerIsAppearing {
                if customInputViewControllerIsAppearing {
                    customInputViewController?.beginAppearanceTransition(true, animated: true)
                }
                else {
                    customInputViewController?.endAppearanceTransition()
                }
            }
        }
    }
    
    private var customInputViewController: UIViewController?
    
    lazy var stickerInputController: CustomInputDisplayOptions = {
        let dependencyManager: VDependencyManager = self.dependencyManager.stickerTrayDependency!
        let stickerTray = StickerTrayViewController.new(withDependencyManager: dependencyManager)
        stickerTray.delegate = self
        return CustomInputDisplayOptions(viewController: stickerTray, desiredHeight: Constants.stickerInputAreaHeight)
    }()
    
    lazy var gifInputController: CustomInputDisplayOptions = {
        let dependencyManager: VDependencyManager = self.dependencyManager.gifTrayDependency!
        let gifTray = GIFTrayViewController.new(withDependencyManager: dependencyManager)
        gifTray.delegate = self
        return CustomInputDisplayOptions(viewController: gifTray, desiredHeight: Constants.gifInputAreaHeight)
    }()
    
    /// Referenced so that it can be set toggled between 0 and it's default
    /// height when shouldShowAttachmentContainer is true
    @IBOutlet weak private var attachmentContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var confirmButtonContainerHeightConstraint: NSLayoutConstraint! {
        didSet {
            confirmButtonContainerHeightConstraint.constant = Constants.minimumConfirmButtonContainerHeight
        }
    }
    @IBOutlet weak private var inputViewToBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var customInputAreaHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var textViewContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private(set) var hashtagBarContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var hashtagBarContainerView: UIView!
    @IBOutlet weak var vipLockContainerView: UIView!
    @IBOutlet weak var vipLockWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var composerLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var backgroundPassthroughContainerView: VPassthroughContainerView!
    @IBOutlet weak private var ballisticsContainerView: VPassthroughContainerView!
    @IBOutlet weak private var ballisticsContainerViewToTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var textView: VPlaceholderTextView!
    
    @IBOutlet weak private var attachmentTabBar: ComposerAttachmentTabBar!
    
    @IBOutlet weak private var attachmentContainerView: UIView!
    @IBOutlet weak private var interactiveContainerView: UIView!
    @IBOutlet weak private var composerBackgroundContainerView: UIView!
    @IBOutlet weak private var confirmButton: TouchableInsetAdjustableButton! {
        didSet {
            confirmButton.applyCornerRadius()
        }
    }
    
    @IBOutlet weak private var confirmButtonContainer: UIView!
    
    private var searchTextChanged = false
    
    private var selectedAsset: ContentMediaAsset? {
        didSet {
            updateConfirmButtonState()
        }
    }
    
    private var composerTextViewManager: ComposerTextViewManager?
    private var keyboardManager: VKeyboardNotificationManager?
    
    private var totalComposerHeight: CGFloat {
        guard isViewLoaded && composerIsVisible else {
            return 0
        }
        return fabs(inputViewToBottomConstraint.constant)
            + textViewContainerHeightConstraint.constant
            + attachmentContainerHeightConstraint.constant
            + hashtagBarContainerHeightConstraint.constant
            + customInputAreaHeightConstraint.constant
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
    
    private var selectedButton: UIButton? {
        didSet {
            oldValue?.isEnabled = true
            if let button = selectedButton {
                button.isEnabled = false
            }
        }
    }
    
    private var shouldShowAttachmentContainer: Bool {
        guard let attachmentMenuItems = attachmentMenuItems, isViewLoaded else {
            return false
        }
        
        if dependencyManager.alwaysShowAttachmentBar == true {
            return true
        }
        
        let interactingWithComposer = textViewIsEditing || customInputAreaHeight != 0
        return !attachmentMenuItems.isEmpty && interactingWithComposer
    }
    
    weak var delegate: ComposerDelegate? {
        didSet {
            setupAttachmentTabBar()
        }
    }
    
    private var userIsOwner: Bool {
        return VCurrentUser.user?.accessLevel.isCreator == true
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
        
        if self.textView.isFirstResponder {
            self.updateViewsForNewVisibleKeyboardHeight(visibleKeyboardHeight: endFrame.height, animationOptions: UIViewAnimationOptions(rawValue: UInt(animationCurve.rawValue << 16)), animationDuration: animationDuration)
        }
    }
    
    private lazy var hideKeyboardBlock: VKeyboardManagerKeyboardChangeBlock = { startFrame, endFrame, animationDuration, animationCurve in
        
        self.composerTextViewManager?.endEditing(self.textView)
        self.updateViewsForNewVisibleKeyboardHeight(visibleKeyboardHeight: 0, animationOptions: UIViewAnimationOptions(rawValue: UInt(animationCurve.rawValue << 16)), animationDuration: animationDuration)
    }
    
    // MARK: - Composer
    
    var maximumTextInputHeight = CGFloat.greatestFiniteMagnitude
    
    var text: String {
        get {
            return textView?.text ?? ""
        }
        set {
            textView?.text = newValue
        }
    }
    
    func showKeyboard() {
        textView.becomeFirstResponder()
    }
    
    var topInset: CGFloat = 0 {
        didSet {
            if topInset != oldValue {
                view.setNeedsUpdateConstraints()
            }
        }
    }
    
    func dismissKeyboard(_ animated: Bool) {
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
    
    func append(_ text: String) {
        guard !text.isEmpty else {
            return
        }
        
        let whitespaceCharacterSet = CharacterSet.whitespacesAndNewlines
        
        if
            let lastCharacter = textView.text?.characters.last,
            let scalar = UnicodeScalar(String(lastCharacter)),
            !whitespaceCharacterSet.contains(scalar)
        {
            let _ = composerTextViewManager?.appendTextIfPossible(textView, text: " " + text + " ")
        }
        else {
            let _ = composerTextViewManager?.appendTextIfPossible(textView, text: text + " ")
        }
        
        textViewHasText = true
    }
    
    // MARK: - Managing visibiliity
    
    private var feedIsFiltered = false {
        didSet {
            updateVisibility(animated: true)
        }
    }
    
    private var feedIsChatRoom = false {
        didSet {
            updateVisibility(animated: true)
        }
    }
    
    private var composerIsVisible = true
    
    private func updateVisibility(animated: Bool) {
        let composerShouldBeVisible = !feedIsFiltered || feedIsChatRoom
        
        guard composerShouldBeVisible != composerIsVisible else {
            return
        }
        
        if animated {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.updateVisibility(animated: false)
                self.view.layoutIfNeeded()
            }
        }
        else {
            inputViewToBottomConstraint.constant = composerShouldBeVisible ? 0.0 : -totalComposerHeight
            if !composerShouldBeVisible {
                textView.resignFirstResponder()
            }
            composerIsVisible = composerShouldBeVisible
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
    
    func hashtagBarController(_ hashtagBarController: HashtagBarController, selectedHashtag hashtag: String) {
        
        guard let (_, range) = textViewCurrentHashtag else {
            return
        }
        
        let replacementText = hashtag + " "
        if composerTextViewManager?.replaceTextInRange(range, withText: replacementText, inTextView: textView) == true {
            hashtagBarController.searchText = nil
        }
    }
    
    // MARK: - HashtagBarControllerAnimationDelegate
    
    func hashtagBarViewController(_ hashtagBarViewController: HashtagBarViewController, isUpdatingConstraints updateBlock: () -> Void) {
        updateBlock()
        searchTextChanged = true
        view.setNeedsUpdateConstraints()
    }
    
    // MARK: - ComposerTextViewManagerDelegate
    
    var textViewHasText: Bool = false {
        didSet {
            updateConfirmButtonState()
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
                if textViewIsEditing {
                    update(toInputAreaState: .hidden)
                }
                view.setNeedsUpdateConstraints()
            }
        }
    }
    
    var textViewPrependedImage: UIImage? {
        didSet {
            if oldValue != textViewPrependedImage {
                updateAttachmentButtons()
                
                vipButton?.isEnabled = vipButton?.isEnabled ?? false || !textViewHasPrependedImage
                if selectedAsset?.contentType == .gif {
                    vipButton?.isSelected = false
                }
            }
        }
    }
    
    func updateAttachmentButtons() {
        attachmentTabBar.buttonsEnabled = !textViewHasPrependedImage
        attachmentTabBar.setButtonEnabled(true, forIdentifier: ComposerInputAttachmentType.Hashtag.rawValue)
        
        let gifEnabled = vipButton?.isSelected == true ? false : !textViewHasPrependedImage
        attachmentTabBar.setButtonEnabled(gifEnabled, forIdentifier: ComposerInputAttachmentType.GIFFlow.rawValue)
        
        if !textViewHasPrependedImage {
            selectedAsset = nil
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
    
    func textViewDidHitCharacterLimit(_ textView: UITextView) {
        textView.v_performShakeAnimation()
    }
    
    func inputTextAttributes() -> (inputTextColor: UIColor?, inputTextFont: UIFont?) {
        return (dependencyManager.inputTextColor, dependencyManager.inputTextFont)
    }
    
    private func updateConfirmButtonState() {
        let hasContentInTextView = textViewHasText || selectedAsset != nil
        confirmButton.isEnabled = hasContentInTextView && customInputAreaState == .hidden
        confirmButton.backgroundColor = confirmButton.isEnabled ? dependencyManager.confirmButtonBackgroundColorEnabled : dependencyManager.confirmButtonBackgroundColorDisabled
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundPassthroughContainerView.delegate = self
        ballisticsContainerView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(setupUserDependentUI), name: NSNotification.Name(rawValue: VCurrentUser.userDidUpdateNotificationKey), object: nil)
        setupUserDependentUI()
        
        //Setup once-initialized properties that cannot be created on initialization
        keyboardManager = VKeyboardNotificationManager(keyboardWillShow: showKeyboardBlock, willHide: hideKeyboardBlock, willChangeFrameBlock: showKeyboardBlock)
        
        maximumTextInputHeight = view.bounds.height * Constants.maximumComposerToScreenRatio
        
        //Setup and style views
        setupAttachmentTabBar()
        setupTextView()
        updateAppearanceFromDependencyManager()
        composerTextViewManager = ComposerTextViewManager(textView: textView, delegate: self, maximumTextLength: maximumTextLength)
        setupHashtagBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(mainFeedFilterDidChange), name: NSNotification.Name(rawValue: RESTForumNetworkSource.updateStreamURLNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.composer(self, didUpdateContentHeight: totalComposerHeight)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        composerTextViewManager?.endEditing(self.textView)
    }
    
    override func updateViewConstraints() {
        let confirmButtonContainerHeight = confirmButtonContainer.bounds.height
        if confirmButtonContainerHeight != abs(confirmButton.touchInsets.vertical) {
            confirmButton.touchInsets = UIEdgeInsetsMake(-confirmButtonContainerHeight / 2, -Constants.confirmButtonHorizontalInset, -confirmButtonContainerHeight / 2, -Constants.confirmButtonHorizontalInset)
        }
        
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
        
        let customInputAreaHeightNeedsUpdate = customInputAreaHeightConstraint.constant != customInputAreaHeight
        if customInputAreaHeightNeedsUpdate {
            customInputAreaHeightConstraint.constant = customInputAreaHeight
        }
        
        let ballisticsTopConstraintNeedsUpdate = ballisticsContainerViewToTopConstraint.constant != topInset
        if ballisticsTopConstraintNeedsUpdate {
            ballisticsContainerViewToTopConstraint.constant = topInset
        }
        
        guard attachmentContainerHeightNeedsUpdate ||
            textViewContainerHeightNeedsUpdate ||
            textViewHeightNeedsUpdate ||
            customInputAreaHeightNeedsUpdate ||
            ballisticsTopConstraintNeedsUpdate ||
            searchTextChanged else {
            // No reason to lay out views again
            super.updateViewConstraints()
            return
        }
        
        searchTextChanged = false
        
        let previousContentOffset = textView.contentOffset
        UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: .allowUserInteraction, animations: {
            self.delegate?.composer(self, didUpdateContentHeight: self.totalComposerHeight)
            if textViewHeightNeedsUpdate {
                self.textView.layoutIfNeeded()
                self.textView.setContentOffset(previousContentOffset, animated: false)
            }
        }, completion: nil)
        
        super.updateViewConstraints()
    }
    
    // MARK: - View updating
    
    private func updateViewsForNewVisibleKeyboardHeight(visibleKeyboardHeight: CGFloat, animationOptions: UIViewAnimationOptions, animationDuration: Double) {
        guard self.visibleKeyboardHeight != visibleKeyboardHeight && composerIsVisible else {
            return
        }
        self.visibleKeyboardHeight = visibleKeyboardHeight
        updateViewConstraints()
        if animationDuration != 0 {
            UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: {
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
    
    private func updateCustomInputAreaHeight(animated: Bool) {
        self.customInputAreaHeightConstraint.constant = self.customInputAreaHeight
        if animated {
            UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
                self.delegate?.composer(self, didUpdateContentHeight: self.totalComposerHeight)
                self.view.layoutIfNeeded()
                }, completion: { _ in
                    self.customInputViewControllerIsAppearing = false
                }
            )
        } else {
            view.setNeedsUpdateConstraints()
            delegate?.composer(self, didUpdateContentHeight: totalComposerHeight)
            customInputViewControllerIsAppearing = false
        }
    }
    
    private func update(toInputAreaState state: CustomInputAreaState) {
        guard customInputAreaState != state else {
            return
        }
        
        customInputAreaState = state
        
        switch customInputAreaState {
            case .hidden:
                customInputAreaHeight = 0
            case .visible(let inputController):
                customInputAreaHeight = inputController.desiredHeight
                update(toCustomInputViewController: inputController.viewController)
                textView.resignFirstResponder()
        }
        updateConfirmButtonState()
        updateCustomInputAreaHeight(animated: true)
        view.setNeedsUpdateConstraints()
    }
    
    private func update(toCustomInputViewController inputViewController: UIViewController) {
        guard customInputViewController != inputViewController else {
            return
        }
        
        if let oldInputViewController = customInputViewController {
            oldInputViewController.willMove(toParentViewController: nil)
            oldInputViewController.view.removeFromSuperview()
            oldInputViewController.removeFromParentViewController()
        }
        customInputViewController = inputViewController
        if let newInputViewController = customInputViewController {
            addChildViewController(newInputViewController)
            customInputViewControllerIsAppearing = true
            let inputView = newInputViewController.view!
            inputView.translatesAutoresizingMaskIntoConstraints = false
            customInputViewContainer.addSubview(inputView)
            customInputViewContainer.topAnchor.constraint(equalTo: inputView.topAnchor).isActive = true
            customInputViewContainer.bottomAnchor.constraint(equalTo: inputView.bottomAnchor).isActive = true
            customInputViewContainer.rightAnchor.constraint(equalTo: inputView.rightAnchor).isActive = true
            customInputViewContainer.leftAnchor.constraint(equalTo: inputView.leftAnchor).isActive = true
            customInputViewContainer.layoutIfNeeded()
            newInputViewController.didMove(toParentViewController: self)
        }
    }
    
    // MARK: - Subview setup
    
    private dynamic func setupUserDependentUI() {
        let isOwner = userIsOwner
        maximumTextLength = dependencyManager.maximumTextLengthForOwner(owner: isOwner)
        attachmentMenuItems = dependencyManager.attachmentMenuItemsForOwner(owner: isOwner)
        updateAppearanceFromDependencyManager()
    }
    
    private func setupTextView() {
        textView.text = nil
        textView.lineFragmentPadding = 0
        textView.placeholderText = dependencyManager.inputPromptText

        if let pastableTextView = textView as? PastableTextView {
            pastableTextView.pastableDelegate = self
        }
    }
    
    private func setupAttachmentTabBar() {
        if isViewLoaded {
            attachmentTabBar.setupWithAttachmentMenuItems(
                attachmentMenuItems,
                maxNumberOfMenuItems: Constants.maximumNumberOfTabs
            )
            attachmentTabBar.delegate = self
        }
    }
    
    private func setupHashtagBar() {
        let hashtagBarViewController = HashtagBarViewController.new(withDependencyManager: dependencyManager, containerHeightConstraint: hashtagBarContainerHeightConstraint)
        addChildViewController(hashtagBarViewController)
        hashtagBarContainerView.addSubview(hashtagBarViewController.view)
        hashtagBarContainerView.v_addFitToParentConstraints(toSubview: hashtagBarViewController.view)
        hashtagBarViewController.animationDelegate = self
        hashtagBarController = hashtagBarViewController.hashtagBarController
    }
    
    private func updateAppearanceFromDependencyManager() {
        guard isViewLoaded else {
            return
        }
        
        textView.font = dependencyManager.inputTextFont
        textView.setPlaceholderFont(dependencyManager.inputTextFont)
        textView.textColor = dependencyManager.inputTextColor
        textView.setPlaceholderTextColor(dependencyManager.inputPlaceholderTextColor)
        textView.keyboardAppearance = dependencyManager.keyboardAppearance
        textView.applyCornerRadius()
        textView.textContainerInset = Constants.composerTextInsets
        textView.backgroundColor = dependencyManager.inputAreaBackgroundColor
        
        confirmButton.setTitleColor(dependencyManager.confirmButtonEnabledTextColor, for: .normal)
        confirmButton.setTitleColor(dependencyManager.confirmButtonDisabledTextColor, for: .disabled)
        confirmButton.titleLabel?.font = dependencyManager.confirmButtonTextFont
        confirmButton.backgroundColor = dependencyManager.confirmButtonBackgroundColorEnabled
        
        attachmentTabBar.tabItemDeselectedTintColor = dependencyManager.tabItemDeselectedTintColor
        attachmentTabBar.tabItemSelectedTintColor = dependencyManager.tabItemSelectedTintColor
        confirmButton.setTitle(dependencyManager.confirmKeyText, for: .normal)
        dependencyManager.addBackground(toBackgroundHost: self)
        
        createVIPButtonIfNeeded()
        
        if let width = vipButton?.intrinsicContentSize.width {
            // If there is a lock
            vipLockWidthConstraint.constant = width
            composerLeadingConstraint.constant = Constants.vipLockComposerMargin
        }
        else {
            // No lock
            vipLockWidthConstraint.constant = 0
            composerLeadingConstraint.constant = 0
        }
        
        view.layoutIfNeeded()
    }
    
    private func createVIPButtonIfNeeded() {
        guard VCurrentUser.user?.accessLevel == .owner else {
            vipButton = nil
            return
        }
        
        if vipButton != nil {
            return
        }
        
        vipButton = dependencyManager.toggleableVIPButton
        if let vipButton = vipButton as? ToggleableImageButton {
            vipButton.delegate = self
            vipLockContainerView.addSubview(vipButton)
            vipLockContainerView.v_addFitToParentConstraints(toSubview: vipButton)
        }
    }
    
    private var vipButton: UIButton? {
        willSet {
            vipButton?.removeFromSuperview()
        }
    }
    
    // MARK: - ToggleableImageButtonDelegate
    
    func button(button: ToggleableImageButton, becameSelected selected: Bool) {
        updateAttachmentButtons()
    }
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return composerBackgroundContainerView
    }
    
    // MARK: - ComposerAttachmentTabBarDelegate
    
    func composerAttachmentTabBar(_ composerAttachmentTabBar: ComposerAttachmentTabBar, didSelectNavigationItem navigationItem: VNavigationMenuItem, fromButton button: UIButton) {
        let identifier = navigationItem.identifier
        let creationFlowType = CreationFlowTypeHelper.creationFlowTypeForIdentifier(identifier)
        var selectedButton: UIButton? = nil
        if creationFlowType != .unknown {
            update(toInputAreaState: .hidden)
            delegate?.composer(self, didSelectCreationFlowType: creationFlowType)
        } else if let composerInputAttachmentType = ComposerInputAttachmentType(rawValue: identifier) {
            switch composerInputAttachmentType {
                case .Hashtag:
                    if !textViewIsEditing {
                        textView.becomeFirstResponder()
                    }
                    let _ = composerTextViewManager?.appendTextIfPossible(textView, text: "#")
                case .StickerTray:
                    selectedButton = button
                    update(toInputAreaState: .visible(inputController: stickerInputController))
                case .GIFTray:
                    selectedButton = button
                    update(toInputAreaState: .visible(inputController: gifInputController))
                default:
                    Log.warning("Encountered unexpected attachment type identifier")
                    update(toInputAreaState: .hidden)
            }
        }
        self.selectedButton = selectedButton
    }
    
    // MARK: - VPassthroughContainerViewDelegate
    
    func passthroughViewRecievedTouch(_ passthroughContainerView: VPassthroughContainerView!) {
        guard passthroughContainerView == backgroundPassthroughContainerView else {
            return
        }
        
        selectedButton = nil
        switch customInputAreaState {
            case .hidden:()
            default:
                update(toInputAreaState: .hidden)
        }
    }
    
    // MARK: - VCreationFlowControllerDelegate
    
    func creationFlowController(_ creationFlowController: VCreationFlowController!, finishedWithPreviewImage previewImage: UIImage!, capturedMediaURL: URL!) {
        guard let contentType = contentType(for: creationFlowController) else {
            creationFlowController.v_showErrorDefaultError()
            return
        }
        
        // Disable VIP button if we just selected a GIF
        vipButton?.isEnabled = contentType != .gif
        
        var preview = previewImage!
        if let image = capturedMediaURL.v_videoPreviewImage, contentType == .gif {
            preview = image
        }
        
        let publishParameters = creationFlowController.publishParameters!
        if let remoteID = publishParameters.assetRemoteId {
            let mediaParameters = ContentMediaAsset.LocalAssetParameters(contentType: contentType, remoteID: remoteID, source: publishParameters.source, size: CGSize(width: publishParameters.width, height: publishParameters.height), url: capturedMediaURL as NSURL?)
            selectedAsset = ContentMediaAsset(initializationParameters: mediaParameters)
        }
        else {
            let size = CGSize(width: publishParameters.width, height: publishParameters.height)
            let mediaParameters = ContentMediaAsset.RemoteAssetParameters(contentType: contentType, url: capturedMediaURL as NSURL, source: publishParameters.source, size: size)
            selectedAsset = ContentMediaAsset(initializationParameters: mediaParameters)
        }
        let maxDimension = view.bounds.width * Constants.maximumAttachmentWidthPercentage
        
        guard let resizedImage = preview.scaledImage(withMaxDimension: maxDimension, upScaling: true) else {
            Log.error("empty resize image")
            return
        }
        let _ = composerTextViewManager?.prependImage(resizedImage, toTextView: textView)
        
        self.dismiss(animated: true) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.view.setNeedsUpdateConstraints()
            let textView = strongSelf.textView!
            textView.becomeFirstResponder()
            textView.selectedRange = NSMakeRange(textView.text.characters.count, 0)
        }
    }
    
    private func contentType(for creationFlowController: VCreationFlowController) -> ContentType? {
        switch creationFlowController.mediaType() {
            case .image:
                return .image
            case .video:
                if type(of: creationFlowController) == VGIFCreationFlowController.self {
                    return .gif
                } else {
                    return .video
                }
            case .unknown:
                assertionFailure("Creation flow controller returned an invalid media type.")
                return nil
        }
    }
    
    func shouldShowPublishScreenForFlowController() -> Bool {
        return false
    }
    
    func creationFlowControllerDidCancel(_ creationFlowController: VCreationFlowController!) {
        creationFlowPresenter.dismissCurrentFlowController()
    }
    
    // MARK: - Actions
    
    @IBAction private func pressedConfirmButton() {
        guard let user = VCurrentUser.user else {
            assertionFailure("Failed to send message due to missing a valid logged in user")
            return
        }
        
        let text = composerTextViewManager?.captionFromTextView(textView)
        
        if
            let asset = selectedAsset,
            let previewImage = textViewPrependedImage
        {
            let isVIPOnly = (vipButton as? ToggleableImageButton)?.isSelected ?? false
            sendMessage(asset: asset, previewImage: previewImage, text: text, currentUser: user, isVIPOnly: isVIPOnly)
        }
        else if let text = text {
            sendMessage(text: text, currentUser: user)
        }
        
        cleanup()
    }

    // MARK: - Send Message
    
    /// Call after a message has been sent to reset the state.
    private func cleanup() {
        composerTextViewManager?.resetTextView(textView)
        selectedAsset = nil
    }
    
    // MARK: - Notifications
    
    private dynamic func mainFeedFilterDidChange(notification: NSNotification) {
        let selectedItem = notification.userInfo?["selectedItem"] as? ListMenuSelectedItem
        feedIsFiltered = selectedItem?.streamAPIPath != nil
        feedIsChatRoom = selectedItem?.chatRoomID != nil
    }
    
    // MARK: - PastableTextViewDelegate
    var canShowPasteMenu: Bool {
        let generalPasteboard = UIPasteboard.general
        let containsStringType = generalPasteboard.contains(pasteboardTypes: UIPasteboardTypeListString as! [String])
        let containsImageType = generalPasteboard.contains(pasteboardTypes: UIPasteboardTypeListImage as! [String])
        let allowsPastingOfImages = dependencyManager.allowsPastingOfImages ?? true
        let allowsPasting = containsStringType || (containsImageType && allowsPastingOfImages)
        
        return allowsPasting
    }
    
    var canShowCopyMenu: Bool {
        return textViewHasText
    }
    
    var canShowCutMenu: Bool {
        return textViewHasText
    }
    
    var canShowSelectMenu: Bool {
        return textViewHasText
    }
    
    func didPasteImage(_ image: (imageObject: UIImage, imageData: Data)) {
        guard let user = VCurrentUser.user else {
            assertionFailure("Failed to send message due to missing a valid logged in user")
            return
        }
        
        guard let imageType = image.imageData.imageType() else {
            Log.debug("Failed to detect the type of image the user pasted.")
            return
        }
        
        do {
            let fileUrl = try TemporaryFileWriter.writeTemporaryData(image.imageData, fileExtension: imageType.fileExtension)
            
            let mediaParameters = ContentMediaAsset.RemoteAssetParameters(contentType: .image, url: fileUrl, source: nil, size: image.imageObject.size)
            if let pastedImageAsset = ContentMediaAsset(initializationParameters: mediaParameters) {
                selectedAsset = pastedImageAsset
                
                // We want GIFs to autopost since they are to be considered as a reaction and not a content creation.
                // We are also making the assumption that all GIFs are animated GIFs...
                if imageType.fileExtension == Constants.gifType {
                    sendMessage(asset: pastedImageAsset, previewImage: image.imageObject, text: nil, currentUser: user, isVIPOnly: false)
                    cleanup()
                } else {
                    let _ = composerTextViewManager?.prependImage(image.imageObject, toTextView: textView)
                }
            }
        } catch {
            Log.debug("failed to write temp image file to disk with error -> \(error)")
        }
    }
    
    func didPasteText(_ text: String) {
        let _ = composerTextViewManager?.insertTextAtSelectionIfPossible(textView, text: text)
    }
    
    // MARK: - TrayDelegate
    
    func tray(_ tray: Tray, selectedAsset asset: ContentMediaAsset, withPreviewImage previewImage: UIImage) {
        guard let currentUser = VCurrentUser.user else {
            Log.warning("Tried to send item from tray with no logged in user")
            return
        }
        let isVIPOnly = (vipButton as? ToggleableImageButton)?.isSelected ?? false
        sendMessage(asset: asset, previewImage: previewImage, text: nil, currentUser: currentUser, isVIPOnly: isVIPOnly)
    }
}

// MARK: - DependecyManager Extension 

private extension VDependencyManager {
    var toggleableVIPButton: UIButton? {
        return button(forKey: "creator.vip.toggle")
    }
    
    func maximumTextLengthForOwner(owner: Bool) -> Int {
        return owner ? 0 : number(forKey: "maximumTextLength")?.intValue ?? 0
    }
    
    var inputPromptText: String {
        return string(forKey: "inputTextPrompt") ?? NSLocalizedString("What do you think?", comment: "")
    }
    
    func attachmentMenuItemsForOwner(owner: Bool) -> [VNavigationMenuItem]? {
        let menuItemKey = owner ? "creatorItems" : "userItems"
        return menuItems(forKey: menuItemKey)
    }
    
    var inputTextColor: UIColor? {
        return color(forKey: VDependencyManagerMainTextColorKey)
    }
    
    var inputPlaceholderTextColor: UIColor? {
        return color(forKey: VDependencyManagerPlaceholderTextColorKey)
    }
    
    var confirmButtonDisabledTextColor: UIColor? {
        return color(forKey: "color.link.disabled")
    }
    
    var confirmButtonEnabledTextColor: UIColor? {
        return color(forKey: "color.link.enabled")
    }
    
    var confirmButtonBackgroundColorEnabled: UIColor? {
        return color(forKey: "color.accent.enabled")
    }
    
    var confirmButtonBackgroundColorDisabled: UIColor? {
        return color(forKey: "color.accent.disabled")
    }
    
    var inputAreaBackgroundColor: UIColor? {
        return color(forKey: "color.accent.secondary")
    }
    
    var inputTextFont: UIFont? {
        return font(forKey: VDependencyManagerParagraphFontKey)
    }
    
    var confirmButtonTextFont: UIFont? {
        return font(forKey: VDependencyManagerLabel4FontKey)
    }
    
    var tabItemDeselectedTintColor: UIColor? {
        return color(forKey: "color.link.deselected")
    }
    
    var tabItemSelectedTintColor: UIColor? {
        return color(forKey: "color.link.selected")
    }
    
    var alwaysShowAttachmentBar: Bool? {
        return number(forKey: "alwaysShowAttachmentBar")?.boolValue
    }
    
    var allowsPastingOfImages: Bool? {
        return number(forKey: "allowsPastingOfImages")?.boolValue
    }
    
    var keyboardAppearance: UIKeyboardAppearance {
        return keyboardStyle(forKey: "keyboardStyle")
    }
    
    var confirmKeyText: String {
        return string(forKey: "confirmKeyText") ?? NSLocalizedString("Send", comment: "")
    }
    
    var gifTrayDependency: VDependencyManager? {
        return childDependency(forKey: "gifTray")
    }
    
    var stickerTrayDependency: VDependencyManager? {
        return childDependency(forKey: "stickerTray")
    }
}
