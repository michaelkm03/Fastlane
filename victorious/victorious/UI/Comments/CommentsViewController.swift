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

class CommentsViewController: UIViewController, UICollectionViewDelegateFlowLayout, VScrollPaginatorDelegate, VTagSensitiveTextViewDelegate, VSwipeViewControllerDelegate, VCommentCellUtilitiesDelegate, VEditCommentViewControllerDelegate, UICollectionViewDataSource, VKeyboardInputAccessoryViewDelegate, VUserTaggingTextStorageDelegate {

    // MARK: - Factory Method
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> CommentsViewController {
        let vc: CommentsViewController = self.v_initialViewControllerFromStoryboard()
        vc.dependencyManager = dependencyManager
        return vc
    }
    
    // MARK: - Public Properties
    
    var dependencyManager: VDependencyManager! {
        didSet {
            if let dependencyManager = dependencyManager {
                navigationItem.title = dependencyManager.stringForKey(VDependencyManagerTitleKey)
            }
        }
    }
    
    var sequence: VSequence? {
        didSet {
            commentsDataSourceSwitcher.sequence = sequence
            if let sequence = sequence {
                self.KVOController.observe( sequence,
                    keyPath: "comments",
                    options: [.New, .Old],
                    block: { (observer, object, change) in
                        self.onCommentsDidChange()
                })
            }
        }
    }
    
    // MARK: - Private Properties
    private let commentsDataSourceSwitcher = CommentsDataSourceSwitchter()
    private var registeredCommentReuseIdentifiers = Set<String>()
    private let scrollPaginator = VScrollPaginator()
    private var publishParameters: VPublishParameters?
    private var mediaAttachmentPresenter: VMediaAttachmentPresenter?
    private var focusHelper: VCollectionViewStreamFocusHelper?
    private var modalTransitioningDelegate = VTransitionDelegate(transition: VSimpleModalTransition())
    private var noContentView: VNoContentView?
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
    
    @IBOutlet private var collectionView: VInputAccessoryCollectionView!
    @IBOutlet private var imageView: UIImageView!
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        focusHelper = VCollectionViewStreamFocusHelper(collectionView: collectionView)
        scrollPaginator.delegate = self
        commentsDataSourceSwitcher.dataSource.loadComments( .First ) { error in
            self.onCommentsDidChange()
        }
        keyboardBar = VKeyboardInputAccessoryView.defaultInputAccessoryViewWithDependencyManager(dependencyManager)
        if let sequence = self.sequence {
            keyboardBar?.sequencePermissions = sequence.permissions
        }
        collectionView.accessoryView = keyboardBar

        noContentView = NSBundle.mainBundle().loadNibNamed("VNoContentView", owner: nil, options: nil).first as? VNoContentView
        if let noContentView = noContentView {
            noContentView.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(noContentView, aboveSubview: imageView)
            view.v_addFitToParentConstraintsToSubview(noContentView)
            noContentView.icon = UIImage(named: "noCommentIcon")
            noContentView.title = NSLocalizedString("NoCommentsTitle", comment:"")
            noContentView.message = NSLocalizedString("NoCommentsMessage", comment:"")
            noContentView.resetInitialAnimationState()
            noContentView.setDependencyManager(dependencyManager)
        }
        
        let mainScreen = UIScreen.mainScreen()
        let maxWidth = mainScreen.bounds.width * mainScreen.scale
        if let sequence = sequence, instreamPreviewURL = sequence.inStreamPreviewImageURLWithMaximumSize(CGSizeMake(maxWidth, CGFloat.max)) {
            
            imageView.setLightBlurredImageWithURL(instreamPreviewURL, placeholderImage: nil)
        }
        
        self.edgesForExtendedLayout = .Bottom
        self.self.extendedLayoutIncludesOpaqueBars = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let keyboardBar = keyboardBar where !firstAppearance && !keyboardBar.isEditing() {
            collectionView.becomeFirstResponder()
        }

        collectionView.accessoryView = keyboardBar
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
    
    private func onCommentsDidChange() {
        if sequence?.comments.array.isEmpty ?? true {
            self.noContentView?.animateTransitionIn()
        }
        else {
            self.noContentView?.resetInitialAnimationState()
        }
        
        if isViewLoaded() {
            collectionView.reloadData()
            focusHelper?.updateFocus()
            updateInsetForKeyboardBarState()
            dispatch_after(0.1) {
                self.collectionView.flashScrollIndicators()
            }
        }
    }

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
        scrollPaginator.scrollViewDidScroll(scrollView)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        focusHelper?.endFocusOnCell(cell)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let comment = commentsDataSourceSwitcher.dataSource.commentAtIndex(indexPath.item)
        let size = VContentCommentsCell.sizeWithFullWidth(CGRectGetWidth(view.bounds),
            comment: comment,
            hasMedia: (comment.commentMediaType() != VCommentMediaType.NoMedia),
            dependencyManager: dependencyManager)
        return CGSize(width: view.bounds.width, height: size.height)
    }

    // MARK: - VScrollPaginatorDelegate
    
    func shouldLoadNextPage() {
        commentsDataSourceSwitcher.dataSource.loadComments(.Next)
    }
    
    func shouldLoadPreviousPage() {
        commentsDataSourceSwitcher.dataSource.loadComments(.Previous)
    }
    
    // MARK: - VSwipeViewControllerDelegate
    
    func backgroundColorForGutter() -> UIColor! {
        return UIColor(white: 0.96, alpha: 1.0)
    }
    
    func cellWillShowUtilityButtons(cellView: UIView!) {
        if let commentCells = collectionView.visibleCells() as? [VContentCommentsCell] {
            for cell in commentCells {
                if cell != cellView {
                    cell.swipeViewController.hideUtilityButtons()
                }
            }
        }
    }
    
    // MARK: - VTagSensitiveTextViewDelegate
    
    func tagSensitiveTextView(tagSensitiveTextView: VTagSensitiveTextView, tappedTag tag: VTag) {
        if let tag = tag as? VUserTag {
            let profileViewController = dependencyManager.userProfileViewControllerWithRemoteId(tag.remoteId)
            self.navigationController?.pushViewController(profileViewController, animated: true)
        }
        else {
            let justHashTagText = (tag.displayString.string as NSString).substringFromIndex(1)
            let hashtagViewController = dependencyManager.hashtagStreamWithHashtag(justHashTagText)
            self.navigationController?.pushViewController(hashtagViewController, animated: true)
        }
    }
    
    func editComment(comment: VComment) {
        let editViewController = VEditCommentViewController.instantiateFromStoryboardWithComment(comment)
        editViewController.transitioningDelegate = modalTransitioningDelegate
        editViewController.delegate = self
        self.presentViewController(editViewController, animated: true, completion: nil)
    }
    
    func replyToComment(comment: VComment) {
        
        let item = self.commentsDataSourceSwitcher.dataSource.indexOfComment(comment)
        let indexPath = NSIndexPath(forItem: item, inSection: 0)
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredVertically, animated: true)
        keyboardBar?.setReplyRecipient(comment.user)
        keyboardBar?.startEditing()
    }
    
    func viewControllerForAlerts() -> UIViewController {
        return self
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
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return commentsDataSourceSwitcher.dataSource.numberOfComments
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let commentForIndexPath = commentsDataSourceSwitcher.dataSource.commentAtIndex(indexPath.item)
        let reuseIdentifierForComment = MediaAttachmentView.reuseIdentifierForComment(commentForIndexPath)
        if !registeredCommentReuseIdentifiers.contains(reuseIdentifierForComment) {
            collectionView.registerNib(VContentCommentsCell.nibForCell(), forCellWithReuseIdentifier: reuseIdentifierForComment)
            registeredCommentReuseIdentifiers.insert(reuseIdentifierForComment)
        }
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifierForComment, forIndexPath: indexPath) as? VContentCommentsCell {
            cell.dependencyManager = dependencyManager
            cell.comment = commentForIndexPath
            cell.commentAndMediaView?.textView?.tagTapDelegate = self
            cell.swipeViewController.controllerDelegate = self
            cell.commentsUtilitiesDelegate = self
            cell.onUserProfileTapped = { [weak self] in
                if let strongSelf = self {
                    let profileViewController = strongSelf.dependencyManager.userProfileViewControllerWithUser(commentForIndexPath.user)
                    strongSelf.navigationController?.pushViewController(profileViewController, animated: true)
                }
            }
            cell.commentAndMediaView?.onMediaTapped = { [weak self, weak cell](previewImage: UIImage?) in
                
                guard let strongSelf = self, strongCell = cell, commentAndMediaView = strongCell.commentAndMediaView, previewImage = previewImage else {
                    return
                }
                
                strongSelf.showLightBoxWithMediaURL(strongCell.comment.properMediaURLGivenContentType(),
                    previewImage: previewImage,
                    isVideo: strongCell.mediaIsVideo,
                    sourceView: commentAndMediaView)
            }
            return cell
        }
        
        fatalError("We must have registered a cell for this comment!")
    }
    
    // MARK: LightBox
    
    func showLightBoxWithMediaURL(mediaURL: NSURL, previewImage: UIImage, isVideo: Bool, sourceView: UIView) {
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
    
    // MARK: - VKeyboardInputAccessoryViewDelegate
    
    func pressedSendOnKeyboardInputAccessoryView(inputAccessoryView: VKeyboardInputAccessoryView) {
        if let sequence = self.sequence {
            let commentParameters = CommentParameters(
                sequenceID: Int64(sequence.remoteId)!,
                text: inputAccessoryView.composedText,
                replyToCommentID: nil,
                mediaURL: self.publishParameters?.mediaToUploadURL,
                mediaType: self.publishParameters?.commentMediaAttachmentType,
                realtimeComment: nil
            )
            if let operation = CommentAddOperation(commentParameters: commentParameters, publishParameters: publishParameters) {
                operation.queue()
                self.keyboardBar?.clearTextAndResign()
                self.publishParameters?.mediaToUploadURL = nil
            }
        }
    }
    
    func keyboardInputAccessoryView(inputAccessoryView: VKeyboardInputAccessoryView, selectedAttachmentType attachmentType: VKeyboardBarAttachmentType) {
        inputAccessoryView.stopEditing()
        self.addMediaToCommentWithAttachmentType(attachmentType)
    }
    
    func keyboardInputAccessoryViewWantsToClearMedia(inputAccessoryView: VKeyboardInputAccessoryView) {
        
        let shouldResumeEditing = inputAccessoryView.isEditing()
        inputAccessoryView.stopEditing()
        
        let alertController = VCommentAlertHelper.alertForConfirmDiscardMediaWithDelete(
            {
                self.publishParameters?.mediaToUploadURL = nil
                inputAccessoryView.setSelectedThumbnail(nil)
                if shouldResumeEditing {
                    inputAccessoryView.startEditing()
                }
            },
            cancel: {
                if shouldResumeEditing {
                    inputAccessoryView.startEditing()
                }
            }
        )
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func keyboardInputAccessoryViewDidBeginEditing(inpoutAccessoryView: VKeyboardInputAccessoryView) {
        updateInsetForKeyboardBarState()
    }
    
    func keyboardInputAccessoryViewDidEndEditing(inpoutAccessoryView: VKeyboardInputAccessoryView) {
        updateInsetForKeyboardBarState()
    }
    
    func addMediaToCommentWithAttachmentType(attachmentType: VKeyboardBarAttachmentType) {
        
        mediaAttachmentPresenter = VMediaAttachmentPresenter(dependencymanager: dependencyManager)
        
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
        userTaggingDismissButton.addTarget(keyboardBar, action: "stopEditing", forControlEvents: .TouchUpInside)
    }
    
    func userTaggingTextStorage(textStorage: VUserTaggingTextStorage, wantsToDismissViewController viewController: UIViewController) {
        
        userTaggingDismissButton.removeFromSuperview()
        viewController.view.removeFromSuperview()
        keyboardBar?.attachmentsBarHidden = false
    }
}
