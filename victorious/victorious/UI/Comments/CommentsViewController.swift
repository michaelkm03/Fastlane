//
//  CommentsViewController.swift
//  victorious
//
//  Created by Michael Sena on 8/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VDependencyManager {
    
    func commentsViewController(sequence: VSequence) -> CommentsViewController? {
        if let commentsViewController = self.templateValueOfType(CommentsViewController.self, forKey: "commentsScreen") as? CommentsViewController {
            commentsViewController.sequence = sequence
            return commentsViewController
        }
        else {
            return nil
        }
    }
}

class CommentsViewController: UIViewController, UICollectionViewDelegateFlowLayout, VTagSensitiveTextViewDelegate, VSwipeViewControllerDelegate, VCommentCellUtilitiesDelegate, VEditCommentViewControllerDelegate, VKeyboardInputAccessoryViewDelegate, VUserTaggingTextStorageDelegate, VPaginatedDataSourceDelegate {
    
    private static let kDefaultBackgroundColorAlpha: CGFloat = 0.35

    // MARK: - Factory Method
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> CommentsViewController {
        let vc: CommentsViewController = self.v_initialViewControllerFromStoryboard()
        vc.dependencyManager = dependencyManager
        return vc
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_: )), forControlEvents: .ValueChanged)
        self.collectionView.addSubview( refreshControl )
        return refreshControl
    }()
    
    private(set) var topInset: CGFloat = 0.0
    
    func positionRefreshControl() {
        if let subview = refreshControl.subviews.first {
            subview.center = CGPoint(
                x: self.refreshControl.bounds.midX,
                y: self.refreshControl.bounds.midY + self.topInset * 0.5
            )
        }
    }
    
    // MARK: - Public Properties
    
    var dependencyManager: VDependencyManager! {
        didSet {
            if let dependencyManager = dependencyManager {
                navigationItem.title = dependencyManager.stringForKey(VDependencyManagerTitleKey)
            }
        }
    }
    
    lazy var dataSource: CommentsDataSource? = {
        if let sequence = self.sequence, let dependencyManager = self.dependencyManager {
            let dataSource = CommentsDataSource(sequence: sequence, dependencyManager: dependencyManager)
            self.collectionView.dataSource = dataSource
            dataSource.delegate = self
            return dataSource
        }
        return nil
    }()
    
    var sequence: VSequence? {
        didSet {
            if sequence == nil {
                dataSource = nil
            }
        }
    }
    
    lazy private var noContentView: VNoContentView = {
        let noContentView: VNoContentView = VNoContentView.v_fromNib()
        noContentView.icon = UIImage(named: "noCommentIcon")
        noContentView.title = NSLocalizedString("NoCommentsTitle", comment:"")
        noContentView.message = NSLocalizedString("NoCommentsMessage", comment:"")
        noContentView.resetInitialAnimationState()
        noContentView.setDependencyManager(self.dependencyManager)
        return noContentView
    }()
    
    // MARK: - Private Properties
    
    private var publishParameters: VPublishParameters?
    private var mediaAttachmentPresenter: VMediaAttachmentPresenter?
    private var focusHelper: VCollectionViewStreamFocusHelper?
    private var modalTransitioningDelegate = VTransitionDelegate(transition: VSimpleModalTransition())
    private var keyboardBar: VKeyboardInputAccessoryView? {
        didSet {
            if let keyboardBar = keyboardBar {
                keyboardBar.translatesAutoresizingMaskIntoConstraints = false
                keyboardBar.delegate = self
                keyboardBar.textStorageDelegate = self
            }
        }
    }
    private var firstAppearance = true
    lazy private var userTaggingDismissButton: DismissButton = DismissButton()
    
    // MARK: Outlets
    
    @IBOutlet private weak var collectionView: VInputAccessoryCollectionView!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource?.registerCells( collectionView )
        
        focusHelper = VCollectionViewStreamFocusHelper(collectionView: collectionView)
        keyboardBar = VKeyboardInputAccessoryView.defaultInputAccessoryViewWithDependencyManager(dependencyManager)
        if let sequence = self.sequence {
            keyboardBar?.sequencePermissions = sequence.permissions
        }
        collectionView.accessoryView = keyboardBar
        
        self.positionRefreshControl()
    
        let mainScreen = UIScreen.mainScreen()
        let maxWidth = mainScreen.bounds.width * mainScreen.scale
        if let instreamPreviewURL = self.sequence?.inStreamPreviewImageURLWithMaximumSize(CGSizeMake(maxWidth, CGFloat.max))
            where !instreamPreviewURL.absoluteString.characters.isEmpty {
                self.backgroundImageView.setLightBlurredImageWithURL(instreamPreviewURL, placeholderImage: nil)
                self.backgroundImageView.backgroundColor = UIColor.clearColor()
        
        } else {
            self.backgroundImageView.image = nil
            let templateColor = self.dependencyManager.colorForKey(VDependencyManagerSecondaryAccentColorKey)
            self.backgroundImageView.backgroundColor = templateColor.colorWithAlphaComponent(CommentsViewController.kDefaultBackgroundColorAlpha)
        }
        self.refresh()
        
        self.edgesForExtendedLayout = .Bottom
        self.extendedLayoutIncludesOpaqueBars = true
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.v_navigationController() == nil && self.topInset != self.topLayoutGuide.length {
            self.topInset = self.topLayoutGuide.length
           self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    func refresh(sender: AnyObject? = nil) {
        if sender == nil {
            self.refreshControl.beginRefreshing()
        }
        dataSource?.loadComments( .First ) { [weak self] results, error, cancelled in
            if sender == nil {
                // Don't animate on first load
                UIView.performWithoutAnimation() {
                    self?.refreshControl.endRefreshing()
                }
            } else {
                // Don't if user manually pulled to refresh
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let keyboardBar = keyboardBar where !firstAppearance && !keyboardBar.isEditing() {
            collectionView.becomeFirstResponder()
        }

        collectionView.accessoryView = keyboardBar
        
        if AgeGate.isAnonymousUser() {
            collectionView.accessoryView?.hidden = true
        }
        self.updateInsetForKeyboardBarState()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppearance {
            collectionView.becomeFirstResponder()
            firstAppearance = false
        }
        
        // Do this here so that the keyboard bar animates in with pushes
        dispatch_after(0.1) {
            self.updateInsetForKeyboardBarState()
            self.focusHelper?.updateFocus()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        collectionView.resignFirstResponder()
        collectionView.flashScrollIndicators()
        focusHelper?.endFocusOnAllCells()
    }
    
    // MARK: - VNavigationController Support
    
    override func v_prefersNavigationBarHidden() -> Bool {
        return false
    }
    
    // MARK: - Internal Methods

    private func updateInsetForKeyboardBarState() {
        if let currentWindow = view.window, keyboardBar = keyboardBar {
            let obscuredRectInWindow = keyboardBar.obscuredRectInWindow(currentWindow)
            let obscuredRecInOwnView = currentWindow.convertRect(obscuredRectInWindow, toView: view)
            let bottomObscuredHeight = CGRectGetMaxY(view.bounds) - CGRectGetMinY(obscuredRecInOwnView)
            let insetsForKeyboardBarState = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomObscuredHeight, 0)
            collectionView.contentInset = insetsForKeyboardBarState
            collectionView.scrollIndicatorInsets = insetsForKeyboardBarState
            focusHelper?.focusAreaInsets = insetsForKeyboardBarState
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        focusHelper?.updateFocus()
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.section == 0 else {
            return
        }
        
        focusHelper?.endFocusOnCell(cell)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.section == 0 else {
            return
        }
        
        let cell = cell as! VContentCommentsCell
        let comment = dataSource?.visibleItems[indexPath.item] as! VComment
        cell.dependencyManager = dependencyManager
        cell.comment = comment
        cell.commentAndMediaView?.textView?.tagTapDelegate = self
        cell.swipeViewController?.controllerDelegate = self
        cell.commentsUtilitiesDelegate = self
        cell.onUserProfileTapped = { [weak self] in
            if let strongSelf = self {
                guard let profileViewController = strongSelf.dependencyManager.userProfileViewController(for: comment.user) else {
                    return
                }
                strongSelf.navigationController?.pushViewController(profileViewController, animated: true)
            }
        }
        cell.commentAndMediaView?.onMediaTapped = { [weak self, weak cell](previewImage: UIImage?) in
            
            guard let strongSelf = self, strongCell = cell, commentAndMediaView = strongCell.commentAndMediaView else {
                return
            }
            
            strongSelf.showLightBoxWithMediaURL(strongCell.comment.properMediaURLGivenContentType(),
                previewImage: previewImage,
                isVideo: strongCell.mediaIsVideo,
                sourceView: commentAndMediaView)
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return dataSource?.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath) ?? CGSize.zero
    }
    
    // MARK: - VSwipeViewControllerDelegate
    
    func backgroundColorForGutter() -> UIColor! {
        return UIColor(white: 0.96, alpha: 1.0)
    }
    
    func cellWillShowUtilityButtons(cellView: UIView!) {
        if let commentCells = collectionView.visibleCells() as? [VContentCommentsCell] {
            for cell in commentCells {
                if cell != cellView {
                    cell.swipeViewController?.hideUtilityButtons()
                }
            }
        }
    }
    
    // MARK: - VTagSensitiveTextViewDelegate
    
    func tagSensitiveTextView(tagSensitiveTextView: VTagSensitiveTextView, tappedTag tag: VTag) {
        if let tag = tag as? VUserTag, let userID = tag.remoteId?.integerValue {
            let operation = FetchUserOperation(userID: userID)
            operation.queue() { [weak self] op in
                guard let strongSelf = self else {
                    return
                }
                if let user = operation.result, let profileViewController = strongSelf.dependencyManager.userProfileViewController(for: user) {
                    strongSelf.navigationController?.pushViewController(profileViewController, animated: true)
                }
            }
        }
        else {
            let justHashTagText = (tag.displayString.string as NSString).substringFromIndex(1)
            let hashtagViewController = dependencyManager.hashtagStreamWithHashtag(justHashTagText)
            self.navigationController?.pushViewController(hashtagViewController, animated: true)
        }
    }
    
    // MARK: - VCommentCellUtilitiesDelegate
    
    func editComment(comment: VComment) {
        let editViewController = VEditCommentViewController.newWithComment(comment, dependencyManager: self.dependencyManager)
        editViewController.transitioningDelegate = modalTransitioningDelegate
        editViewController.delegate = self
        self.presentViewController(editViewController, animated: true, completion: nil)
    }
    
    func replyToComment(comment: VComment) {
        guard let index = dataSource?.visibleItems.indexOfObject(comment) else {
            return
        }
        
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredVertically, animated: true)
        keyboardBar?.setReplyRecipient(comment.user)
        keyboardBar?.startEditing()
    }
    
    func flagComment(comment: VComment) {
        CommentFlagOperation(commentID: comment.remoteId.integerValue).queue() { results, error, cancelled in
            self.dataSource?.removeDeletedItems()
            self.v_showFlaggedCommentAlert()
        }
    }
    
    func deleteComment(comment: VComment) {
        CommentDeleteOperation(commentID: comment.remoteId.integerValue, removalReason: nil).queue() { results, error, cancelled in
            self.dataSource?.removeDeletedItems()
        }
    }
    
    // MARK: - VEditCommentViewControllerDelegate
    
    func didFinishEditingComment(comment: VComment) {
        dismissViewControllerAnimated(true) {
            for cell in self.collectionView.visibleCells() {
                if let commentCell = cell as? VContentCommentsCell where commentCell.comment.remoteId == comment.remoteId {
                    // Set updated comment on cell
                    commentCell.comment = comment
                    
                    // Try to reload the cell without reloading the whole section
                    let indexPathToInvalidate = self.collectionView.indexPathForCell(commentCell)
                    if let indexPathToInvalidate = indexPathToInvalidate {
                        self.collectionView.performBatchUpdates({ () in
                            self.collectionView.reloadItemsAtIndexPaths([indexPathToInvalidate])
                            }, completion: nil)
                    }
                    else {
                        self.collectionView.reloadSections(NSIndexSet(index: 0))
                    }
                }
            }
        }
    }
    
    // MARK: LightBox
    
    func showLightBoxWithMediaURL(mediaURL: NSURL, previewImage: UIImage?, isVideo: Bool, sourceView: UIView) {
        var lightBox: VLightboxViewController?
        if isVideo {
            lightBox = VVideoLightboxViewController(previewImage: previewImage, videoURL: mediaURL)
        }
        else {
            lightBox = VImageLightboxViewController(image: previewImage)
        }
        lightBox?.onCloseButtonTapped = { [weak lightBox, weak self] in
            if let strongSelf = self where strongSelf.presentedViewController == lightBox {
                strongSelf.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        if let videoLightBox = lightBox as? VVideoLightboxViewController {
            videoLightBox.onVideoFinished = videoLightBox.onCloseButtonTapped
        }
        VLightboxTransitioningDelegate.addNewTransitioningDelegateToLightboxController(lightBox, referenceView: sourceView)
        self.presentViewController(lightBox!, animated: true, completion: nil)
    }
    
    func addComment( text text: String, publishParameters: VPublishParameters?) {
        guard let sequence = self.sequence else {
            return
        }
        
        let mediaAttachment: MediaAttachment?
        if let publishParameters = publishParameters {
            mediaAttachment = MediaAttachment(publishParameters: publishParameters)
        } else {
            mediaAttachment = nil
        }
        
        let creationParameters = Comment.CreationParameters(
            text: text,
            sequenceID: sequence.remoteId,
            replyToCommentID: nil,
            mediaAttachment: mediaAttachment,
            realtimeAttachment: nil
        )
        
        CommentCreateOperation(creationParameters: creationParameters).queue() { results, error, cancelled in
            self.dataSource?.loadNewComments()
        }
        self.keyboardBar?.clearTextAndResign()
        self.publishParameters?.mediaToUploadURL = nil
    }
    
    // MARK: - VKeyboardInputAccessoryViewDelegate
    
    func pressedSendOnKeyboardInputAccessoryView(inputAccessoryView: VKeyboardInputAccessoryView) {
        self.addComment(text: inputAccessoryView.composedText, publishParameters: self.publishParameters)
    }

    func keyboardInputAccessoryView(inputAccessoryView: VKeyboardInputAccessoryView, selectedAttachmentType attachmentType: VKeyboardBarAttachmentType) {
        inputAccessoryView.stopEditing()
        self.addMediaToCommentWithAttachmentType(attachmentType)
    }
    
    func keyboardInputAccessoryViewWantsToClearMedia(inputAccessoryView: VKeyboardInputAccessoryView) {
        
        let shouldResumeEditing = inputAccessoryView.isEditing()
        inputAccessoryView.stopEditing()
        
        let promptOperation = ShowMediaDeletionPromptOperation(originViewController: self)
        promptOperation.queue() { [weak self] _ in
            
            if promptOperation.confirmedDelete {
                self?.publishParameters?.mediaToUploadURL = nil
                inputAccessoryView.setSelectedThumbnail(nil)
            }
            
            if shouldResumeEditing {
                inputAccessoryView.startEditing()
            }
            
        }
    }
    
    func keyboardInputAccessoryViewDidBeginEditing(inpoutAccessoryView: VKeyboardInputAccessoryView) {
        updateInsetForKeyboardBarState()
    }
    
    func keyboardInputAccessoryViewDidEndEditing(inpoutAccessoryView: VKeyboardInputAccessoryView) {
        updateInsetForKeyboardBarState()
    }
    
    func addMediaToCommentWithAttachmentType(attachmentType: VKeyboardBarAttachmentType) {
        
        mediaAttachmentPresenter = VMediaAttachmentPresenter(dependencyManager: dependencyManager)
        
        let mediaAttachmentOptions: VMediaAttachmentOptions = {
            switch attachmentType {
            case .Video:
                return VMediaAttachmentOptions.Video
            case .GIF:
                return VMediaAttachmentOptions.GIF
            case .Image:
                return VMediaAttachmentOptions.Image
            }
        }()

        if let mediaAttachmentPresenter = mediaAttachmentPresenter {
            mediaAttachmentPresenter.attachmentTypes = mediaAttachmentOptions
            mediaAttachmentPresenter.resultHandler = { [weak self](success: Bool, publishParameters: VPublishParameters?) in
                if let strongSelf = self {
                    strongSelf.publishParameters = publishParameters
                    strongSelf.mediaAttachmentPresenter = nil
                    strongSelf.keyboardBar?.setSelectedThumbnail(publishParameters?.previewImage)
                    strongSelf.keyboardBar?.startEditing()
                    strongSelf.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            mediaAttachmentPresenter.presentOnViewController(self)
        }
    }
    
    // MARK: - VUserTaggingTextStorageDelegate
    
    func userTaggingTextStorage(textStorage: VUserTaggingTextStorage, wantsToShowViewController viewController: UIViewController) {
        
        keyboardBar?.attachmentsBarHidden = true
        
        let searchTableView = viewController.view
        searchTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchTableView)
        if let ownWindow = view.window, keyboardBar = keyboardBar {
            let obscuredRectInWindow = keyboardBar.obscuredRectInWindow(ownWindow)
            let obscuredRectInOwnView = ownWindow.convertRect(obscuredRectInWindow, toView: view)
            let obscuredBottom = view.bounds.height - obscuredRectInOwnView.minY
            view.v_addFitToParentConstraintsToSubview(searchTableView, leading: 0, trailing: 0, top: topLayoutGuide.length, bottom: obscuredBottom)
        }
        view.addSubview(userTaggingDismissButton)
        let dismissButtonMarginToBorder: CGFloat = 8.0
        view.v_addPinToTopToSubview(userTaggingDismissButton, topMargin: dismissButtonMarginToBorder)
        view.v_addPinToTrailingEdgeToSubview(userTaggingDismissButton, trailingMargin: dismissButtonMarginToBorder)
        userTaggingDismissButton.addTarget(keyboardBar, action: #selector(VKeyboardInputAccessoryView.stopEditing), forControlEvents: .TouchUpInside)
    }
    
    func userTaggingTextStorage(textStorage: VUserTaggingTextStorage, wantsToDismissViewController viewController: UIViewController) {
        
        userTaggingDismissButton.removeFromSuperview()
        viewController.view.removeFromSuperview()
        keyboardBar?.attachmentsBarHidden = false
    }
    
    // MARK: - VPaginatedDataSourceDelegate
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: VDataSourceState, to newState: VDataSourceState) {
        
        if let dataSource = self.dataSource {
            let wasHidden = dataSource.activityFooterDataSource.hidden
            let canScroll = collectionView.contentSize.height > collectionView.bounds.height
            let shouldHide = !paginatedDataSource.shouldShowNextPageActivity || !canScroll
            dataSource.activityFooterDataSource.hidden = shouldHide
            if wasHidden != shouldHide {
                collectionView.reloadSections(NSIndexSet(index: 1))
            }
        }
        
        self.updateCollectionView()
    }
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        
        collectionView.v_applyChangeInSection(0, from: oldValue, to: newValue, animated: true)
        
        focusHelper?.updateFocus()
        
        dispatch_after(0.1) {
            self.collectionView.flashScrollIndicators()
        }
    }
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didReceiveError error: NSError) {
        self.v_showErrorDefaultError()
    }
    
    func updateCollectionView() {
        
        let isAlreadyShowingNoContent = collectionView.backgroundView == self.noContentView
        switch self.dataSource?.state ?? .Cleared {
            
        case .Error, .NoResults, .Loading where isAlreadyShowingNoContent:
            guard let collectionView = self.collectionView else {
                break
            }
            if !isAlreadyShowingNoContent {
                self.noContentView.resetInitialAnimationState()
                self.noContentView.animateTransitionIn()
            }
            collectionView.backgroundView = self.noContentView
            self.refreshControl.layer.zPosition = (collectionView.backgroundView?.layer.zPosition ?? 0) + 1
            
        default:
            self.collectionView.backgroundView = nil
        }
    }
}
