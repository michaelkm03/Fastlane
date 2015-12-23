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

class CommentsViewController: UIViewController, UICollectionViewDelegateFlowLayout, VScrollPaginatorDelegate, VTagSensitiveTextViewDelegate, VSwipeViewControllerDelegate, VCommentCellUtilitiesDelegate, VEditCommentViewControllerDelegate, UICollectionViewDataSource, VKeyboardInputAccessoryViewDelegate, VUserTaggingTextStorageDelegate, PaginatedDataSourceDelegate {

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
    
    /// A `CommentsDataSource` conformant object. Consumers should call methods on this variable when determining the state of the comments.
    var dataSource: SequenceCommentsDataSource? {
        didSet {
            dataSource?.delegate = self
        }
    }
    
    var sequence: VSequence? {
        didSet {
            if let sequence = sequence {
                dataSource = SequenceCommentsDataSource(sequence: sequence)
            } else {
                dataSource = nil
            }
        }
    }
    
    // MARK: - Private Properties
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
    
    @IBOutlet private weak var collectionView: VInputAccessoryCollectionView!
    @IBOutlet private weak var imageView: UIImageView!
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        focusHelper = VCollectionViewStreamFocusHelper(collectionView: collectionView)
        scrollPaginator.delegate = self
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
        self.extendedLayoutIncludesOpaqueBars = true
        
        dataSource?.loadComments( .First )
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
        scrollPaginator.scrollViewDidScroll(scrollView)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        focusHelper?.endFocusOnCell(cell)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard let comment = dataSource?.visibleItems[ indexPath.item ] as? VComment else {
            fatalError( "Unable to find comment to display" )
        }
        
        let size = VContentCommentsCell.sizeWithFullWidth(CGRectGetWidth(view.bounds),
            comment: comment,
            hasMedia: (comment.commentMediaType() != .NoMedia),
            dependencyManager: dependencyManager)
        return CGSize(width: view.bounds.width, height: size.height)
    }

    // MARK: - VScrollPaginatorDelegate
    
    func shouldLoadNextPage() {
        dataSource?.loadComments( .Next )
    }
    
    func shouldLoadPreviousPage() {
        dataSource?.loadComments( .Previous )
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
        guard let index = dataSource?.visibleItems.indexOfObject(comment) else {
            return
        }
        
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
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
        return dataSource?.visibleItems.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        guard let commentForIndexPath = dataSource?.visibleItems[indexPath.item] as? VComment else {
            fatalError( "Unable to find comment to display" )
        }
        
        let reuseIdentifierForComment = MediaAttachmentView.reuseIdentifierForComment(commentForIndexPath)
        if !registeredCommentReuseIdentifiers.contains(reuseIdentifierForComment) {
            collectionView.registerNib(VContentCommentsCell.nibForCell(), forCellWithReuseIdentifier: reuseIdentifierForComment)
            registeredCommentReuseIdentifiers.insert(reuseIdentifierForComment)
        }
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifierForComment, forIndexPath: indexPath) as? VContentCommentsCell else {
            fatalError("We must have registered a cell for this comment!")
        }
        
        cell.dependencyManager = dependencyManager
        cell.comment = commentForIndexPath
        cell.commentAndMediaView?.textView?.tagTapDelegate = self
        cell.swipeViewController?.controllerDelegate = self
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
                sequenceID: sequence.remoteId,
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
    
    // MARK: - PaginatedDataSourceDelegate
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        
        if let noContentView = self.noContentView {
            if newValue.count == 0 {
                noContentView.animateTransitionIn()
            } else {
                noContentView.resetInitialAnimationState()
            }
        }
        
        var insertedIndexPaths = [NSIndexPath]()
        for item in newValue where !oldValue.containsObject( item ) {
            let index = newValue.indexOfObject( item )
            insertedIndexPaths.append( NSIndexPath(forItem: index, inSection: 0) )
        }
        
        var deletedIndexPaths = [NSIndexPath]()
        for item in oldValue where !newValue.containsObject( item ) {
            let index = oldValue.indexOfObject( item )
            deletedIndexPaths.append( NSIndexPath(forItem: index, inSection: 0) )
        }
        
        collectionView.insertItemsAtIndexPaths( insertedIndexPaths )
        collectionView.deleteItemsAtIndexPaths( deletedIndexPaths )
        
        focusHelper?.updateFocus()
        updateInsetForKeyboardBarState()
        dispatch_after(0.1) {
            self.collectionView.flashScrollIndicators()
        }
    }
}
