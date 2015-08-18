//
//  CommentsViewController.swift
//  victorious
//
//  Created by Michael Sena on 8/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension VDependencyManager {
    
    func commentsViewController(sequence: VSequence) -> CommentsViewController? {
        var commentViewController = self.templateValueOfType(CommentsViewController.self, forKey: "commentsScreen") as? CommentsViewController
        commentViewController?.sequence = sequence
        return commentViewController
    }

}

class CommentsViewController: UIViewController, UICollectionViewDelegateFlowLayout, VScrollPaginatorDelegate, VTagSensitiveTextViewDelegate, VSwipeViewControllerDelegate, VCommentCellUtilitiesDelegate, VEditCommentViewControllerDelegate, UICollectionViewDataSource, CommentsDataSourceDelegate, VKeyboardInputAccessoryViewDelegate, VUserTaggingTextStorageDelegate {

    // MARK: - Factory Method
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> CommentsViewController {
        let vc: CommentsViewController = self.v_fromStoryboardInitialViewController()
        vc.dependencyManager = dependencyManager
        return vc
    }
    
    // MARK: - Public Properties
    
    var dependencyManager: VDependencyManager! {
        didSet {
            if let dependencyManager = dependencyManager {
                authorizedAction = VAuthorizedAction(objectManager: VObjectManager.sharedManager(), dependencyManager: dependencyManager)
            }
        }
    }
    
    var sequence: VSequence? {
        didSet {
            commentsDataSourceSwitcher.sequence = sequence
        }
    }
    
    // MARK: - Private Properties
    private let commentsDataSourceSwitcher = CommentsDataSourceSwitchter()
    private var registeredCommentReuseIdentifiers = Set<String>()
    private let scrollPaginator = VScrollPaginator()
    private var authorizedAction: VAuthorizedAction!
    private var publishParameters: VPublishParameters?
    private var mediaAttachmentPresenter: VMediaAttachmentPresenter?
    private var focusHelper: VCollectionViewStreamFocusHelper?
    private var modalTransitioningDelegate = VTransitionDelegate(transition: VSimpleModalTransition())
    private var keyboardBar: VKeyboardInputAccessoryView? {
        didSet {
            if let keyboardBar = keyboardBar {
                keyboardBar.setTranslatesAutoresizingMaskIntoConstraints(false)
                keyboardBar.delegate = self
                keyboardBar.textStorageDelegate = self
            }
        }
    }
    
    // MARK: Outlets
    
    @IBOutlet private var collectionView: VInputAccessoryCollectionView!
    @IBOutlet private var imageView: UIImageView!
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        focusHelper = VCollectionViewStreamFocusHelper(collectionView: collectionView)
        scrollPaginator.delegate = self
        commentsDataSourceSwitcher.dataSource.delegate = self
        keyboardBar = VKeyboardInputAccessoryView.defaultInputAccessoryViewWithDependencyManager(dependencyManager)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        becomeFirstResponder()
        if let sequence = sequence, instreamPreviewURL = sequence.inStreamPreviewImageURL() {
            imageView.applyTintAndBlurToImageWithURL(instreamPreviewURL, withTintColor: nil)
        }

        collectionView.accessoryView = keyboardBar
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Do this here so that the keyboard bar animates in with pushes
        collectionView.becomeFirstResponder()
        keyboardBar?.becomeFirstResponder()
        focusHelper?.updateFocus()
        updateInsetForKeyboardBarState()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.resignFirstResponder()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        focusHelper?.endFocusOnAllCells()
    }
    
    // MARK: - VNavigationController Support
    
    override func v_prefersNavigationBarHidden() -> Bool {
        return false
    }
    
    // MARK: - UIResponder
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override var inputAccessoryView: UIView! {
        return keyboardBar
    }
    
    // MARK: - Internal Methods

    private func updateInsetForKeyboardBarState() {
        if let currentWindow = view.window, keyboardBar = keyboardBar {
            var obscuredRectInWindow = keyboardBar.obscuredRectInWindow(currentWindow)
            var obscuredRecInOwnView = currentWindow.convertRect(obscuredRectInWindow, toView: view)
            var bottomObscuredHeight = CGRectGetMaxY(view.bounds) - CGRectGetMinY(obscuredRecInOwnView)
            var insetsForKeyboardBarState = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomObscuredHeight, 0)
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
        if let comment = sequence?.comments?[indexPath.item] as? VComment {
            var size = VContentCommentsCell.sizeWithFullWidth(CGRectGetWidth(view.bounds),
                comment: comment,
                hasMedia: (comment.commentMediaType() != VCommentMediaType.NoMedia),
                dependencyManager: dependencyManager)
            return CGSize(width: view.bounds.width, height: size.height)
        }
        return CGSize.zeroSize
    }

    // MARK: - VScrollPaginatorDelegate
    
    func shouldLoadNextPage() {
        commentsDataSourceSwitcher.dataSource.loadNextPage()
    }
    
    func shouldLoadPreviousPage() {
        commentsDataSourceSwitcher.dataSource.loadPreviousPage()
    }
    
    // MARK: - VSwipeViewControllerDelegate
    
    func backgroundColorForGutter() -> UIColor! {
        return UIColor(white: 0.96, alpha: 1.0)
    }
    
    func cellWillShowUtilityButtons(cellView: UIView!) {
        
        for cell in collectionView.visibleCells() {
            if cell as! NSObject === cellView {
                continue
            }
            if let commentCell = cell as? VContentCommentsCell {
                commentCell.swipeViewController.hideUtilityButtons()
            }
        }
    }
    
    // MARK: - VTagSensitiveTextViewDelegate
    
    func tagSensitiveTextView(tagSensitiveTextView: VTagSensitiveTextView, tappedTag tag: VTag) {
        if let tag = tag as? VUserTag {
            var profileViewController = dependencyManager.userProfileViewControllerWithRemoteId(tag.remoteId)
            self.navigationController?.pushViewController(profileViewController, animated: true)
        }
        else {
            var justHashTagText = (tag.displayString.string as NSString).substringFromIndex(1)
            var hashtagViewController = dependencyManager.hashtagStreamWithHashtag(justHashTagText)
            self.navigationController?.pushViewController(hashtagViewController, animated: true)
        }
    }
    
    // MARK: - VCommentCellUtilitiesDelegate
    
    func commentRemoved(comment: VComment) {
    }
    
    func commentRemoved(comment: VComment, atIndex index: Int) {
        collectionView.performBatchUpdates({
            self.collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
        }, completion: nil)
    }
    
    func editComment(comment: VComment) {
        var editViewController = VEditCommentViewController.instantiateFromStoryboardWithComment(comment)
        editViewController.transitioningDelegate = modalTransitioningDelegate
        editViewController.delegate = self
        self.presentViewController(editViewController, animated: true, completion: nil)
    }
    
    func replyToComment(comment: VComment) {
        
        var item = self.commentsDataSourceSwitcher.dataSource.indexOfComment(comment)
        var indexPath = NSIndexPath(forItem: item, inSection: 0)
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredVertically, animated: true)
        keyboardBar?.setReplyRecipient(comment.user)
        keyboardBar?.startEditing()
    }
    
    // MARK: - VEditCommentViewControllerDelegate
    
    func didFinishEditingComment(comment: VComment) {
        dismissViewControllerAnimated(true, completion: {
            for cell in self.collectionView.visibleCells() {
                if let commentCell = cell as? VContentCommentsCell where commentCell.comment.remoteId == comment.remoteId {
                    // Set updated comment on cell
                    commentCell.comment = comment
                    
                    // Try to reload the cell without reloading the whole section
                    var indexPathToInvalidate = self.collectionView.indexPathForCell(commentCell)
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
        })
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
        
        if var cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifierForComment, forIndexPath: indexPath) as? VContentCommentsCell {
            cell.dependencyManager = dependencyManager
            cell.comment = commentForIndexPath
            cell.commentAndMediaView.textView.tagTapDelegate = self
            cell.swipeViewController.controllerDelegate = self
            cell.commentsUtilitiesDelegate = self
            cell.onUserProfileTapped = { [weak self] in
                if let strongSelf = self {
                    var profileViewController = strongSelf.dependencyManager.userProfileViewControllerWithUser(commentForIndexPath.user)
                    strongSelf.rootNavigationController()?.innerNavigationController.pushViewController(profileViewController, animated: true)
                }
            }
            return cell
        }
        
        fatalError("We must have registered a cell for this comment!")
    }
    
    // MARK: - CommentsDataSourceDelegate
    
    func commentsDataSourceDidUpdate(dataSource: CommentsDataSource) {
        collectionView.reloadData()
        dispatch_after(0.1) {
            self.focusHelper?.updateFocus()
            self.updateInsetForKeyboardBarState()
        }
    }
    
    func commentsDataSourceDidUpdate(dataSource: CommentsDataSource, deepLinkinkId: NSNumber) {
        collectionView.reloadData()
        focusHelper?.updateFocus()
        updateInsetForKeyboardBarState()
    }

    // MARK: - VKeyboardInputAccessoryViewDelegate
    
    func pressedSendOnKeyboardInputAccessoryView(inputAccessoryView: VKeyboardInputAccessoryView) {
        if let authorizedAction = authorizedAction {
            authorizedAction.performFromViewController(self,
                context: .AddComment,
                completion: { [weak self](authorized: Bool) in
                    if authorized, let strongSelf = self, let sequence = strongSelf.sequence {
                        VObjectManager.sharedManager().addCommentWithText(inputAccessoryView.composedText,
                            publishParameters: strongSelf.publishParameters,
                            toSequence: sequence,
                            andParent: nil,
                            successBlock: { (operation : NSOperation?, result : AnyObject?, resultObjects : [AnyObject]) in
                                strongSelf.collectionView.reloadData()
                            }, failBlock: nil)
                        
                        strongSelf.keyboardBar?.clearTextAndResign()
                        strongSelf.publishParameters?.mediaToUploadURL = nil
                    }
                })
        }
    }
    
    func keyboardInputAccessoryView(inputAccessoryView: VKeyboardInputAccessoryView, selectedAttachmentType attachmentType: VKeyboardBarAttachmentType) {
        
        inputAccessoryView.stopEditing()
        
        self.authorizedAction.performFromViewController(self, context: .AddComment) { [weak self](authorized: Bool) in
            if authorized, let strongSelf = self {
                strongSelf.addMediaToCommentWithAttachmentType(attachmentType)
            }
        }
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
        
        var mediaAttachmentOptions : VMediaAttachmentOptions = {
            switch attachmentType {
            case .Video:
                return VMediaAttachmentOptions.Video
            case .GIF:
                return VMediaAttachmentOptions.GIF
            case .Image:
                return VMediaAttachmentOptions.Image
            }
        }()

        mediaAttachmentPresenter?.attachmentTypes = mediaAttachmentOptions
        mediaAttachmentPresenter?.resultHandler = { [weak self](success: Bool, publishParameters: VPublishParameters?) in
            if let strongSelf = self {
                strongSelf.publishParameters = publishParameters
                strongSelf.mediaAttachmentPresenter = nil
                strongSelf.keyboardBar?.setSelectedThumbnail(publishParameters?.previewImage)
                strongSelf.keyboardBar?.startEditing()
                strongSelf.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        mediaAttachmentPresenter?.presentOnViewController(self)
    }
    
    // MARK: - VUserTaggingTextStorageDelegate
    
    func userTaggingTextStorage(textStorage: VUserTaggingTextStorage, wantsToShowViewController viewController: UIViewController) {
        
        keyboardBar?.attachmentsBarHidden = true
        
        var searchTableView = viewController.view
        searchTableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(searchTableView)
        if let ownWindow = view.window, keyboardBar = keyboardBar {
            var obscuredRectInWindow = keyboardBar.obscuredRectInWindow(ownWindow)
            var obscuredRectInOwnView = ownWindow.convertRect(obscuredRectInWindow, toView: view)
            var obscuredBottom = view.bounds.height - obscuredRectInOwnView.minY
            view.v_addFitToParentConstraintsToSubview(searchTableView, leading: 0, trailing: 0, top: topLayoutGuide.length, bottom: obscuredBottom)
        }
        
    }
    
    func userTaggingTextStorage(textStorage: VUserTaggingTextStorage, wantsToDismissViewController viewController: UIViewController) {
        
        viewController.view.removeFromSuperview()
        keyboardBar?.attachmentsBarHidden = false
    }
    
}
