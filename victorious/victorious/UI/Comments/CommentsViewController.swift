//
//  CommentsViewController.swift
//  victorious
//
//  Created by Michael Sena on 8/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension VDependencyManager {
    
    func commentsViewController(sequence: VSequence) -> CommentsViewController {
        var commentViewController = self.templateValueOfType(CommentsViewController.self, forKey: "commentsScreen") as! CommentsViewController
        commentViewController.sequence = sequence
        return commentViewController
    }
    
    func commentsViewController(sequnce: VSequence, selectedComment: VComment) -> CommentsViewController {
        var addedDependencies: [NSObject : AnyObject] = ["selectedComment" : selectedComment]
        var commentViewController = self.templateValueOfType(CommentsViewController.self, forKey: "commentsScreen", withAddedDependencies: addedDependencies) as! CommentsViewController
        commentViewController.sequence = sequnce
        return commentViewController
    }

}

class CommentsViewController: UIViewController, VKeyboardInputAccessoryViewDelegate, UICollectionViewDataSource, CommentsDataSourceDelegate {

    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> CommentsViewController {
        let vc: CommentsViewController = self.fromStoryboardInitialViewController()
        vc.dependencyManager = dependencyManager
        return vc
    }
    
    private var dependencyManager : VDependencyManager! {
        didSet {
            if let dependencyManager = dependencyManager {
                authorizedAction = VAuthorizedAction(objectManager: VObjectManager.sharedManager(), dependencyManager: dependencyManager)
            }
        }
    }
    private var sequence: VSequence? {
        didSet {
            commentsDataSourceSwitcher.sequence = sequence
        }
    }
    private let commentsDataSourceSwitcher = CommentsDataSourceSwitchter()
    private var registeredCommentReuseIdentifiers = Set<String>()
    private let scrollPaginator = VScrollPaginator()
    private var authorizedAction : VAuthorizedAction!
    private var publishParameters: VPublishParameters?
    private var mediaAttachmentPresenter: VMediaAttachmentPresenter?
    
    // MARK: Outlets
    
    @IBOutlet var collectionView: VInputAccessoryCollectionView!
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollPaginator.delegate = self
        
        commentsDataSourceSwitcher.dataSource.delegate = self
        
        keyboardBar = VKeyboardInputAccessoryView.defaultInputAccessoryViewWithDependencyManager(dependencyManager)
        keyboardBar?.setTranslatesAutoresizingMaskIntoConstraints(false)
        keyboardBar?.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.becomeFirstResponder()
        self.rootNavigationController().setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.accessoryView = keyboardBar
        collectionView.becomeFirstResponder()
        keyboardBar?.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.resignFirstResponder()
        self.rootNavigationController().setNavigationBarHidden(true, animated: true)
    }
    
    // MARK:  Keyboard Bar
    
    private var keyboardBar : VKeyboardInputAccessoryView?
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override var inputAccessoryView: UIView! {
        get {
            return keyboardBar
        }
    }

}

extension CommentsViewController: VKeyboardInputAccessoryViewDelegate {
    
    func pressedSendOnKeyboardInputAccessoryView(inputAccessoryView: VKeyboardInputAccessoryView) {
        if let authorizedAction = authorizedAction {
            authorizedAction.performFromViewController(self,
                context: .AddComment,
                completion: { [weak self](authorized: Bool) -> Void in
                    if !authorized {
                        return
                    }
                    if let strongSelf = self, let sequence = strongSelf.sequence {
                        VObjectManager.sharedManager().addCommentWithText(inputAccessoryView.composedText,
                            publishParameters: strongSelf.publishParameters,
                            toSequence: sequence,
                            andParent: nil,
                            successBlock: { (operation : NSOperation?, result : AnyObject?, resultObjects : [AnyObject]) -> Void in
                                strongSelf.commentsDataSourceSwitcher.dataSource.loadFirstPage()
                            }, failBlock: nil)
                        
                        strongSelf.keyboardBar?.clearTextAndResign()
                        strongSelf.publishParameters?.mediaToUploadURL = nil
                    }
                })
        }
    }
    
    func keyboardInputAccessoryView(inputAccessoryView: VKeyboardInputAccessoryView, selectedAttachmentType attachmentType: VKeyboardBarAttachmentType) {
        
        inputAccessoryView.stopEditing()
        
        self.authorizedAction.performFromViewController(self, context: .AddComment) { [weak self](authorized: Bool) -> Void in
            if !authorized {
                return
            }
            if let strongSelf = self {
                strongSelf.addMediaToCommentWithAttachmentType(attachmentType)
            }
        }
    }
    
    func addMediaToCommentWithAttachmentType(attachmentType: VKeyboardBarAttachmentType) {
        
        mediaAttachmentPresenter = VMediaAttachmentPresenter(dependencymanager: dependencyManager)
        
        var mediaAttachmentOptions : VMediaAttachmentOptions
        switch attachmentType {
        case .Video:
            mediaAttachmentOptions = VMediaAttachmentOptions.Video
        case .GIF:
            mediaAttachmentOptions = VMediaAttachmentOptions.GIF
        case .Image:
            mediaAttachmentOptions = VMediaAttachmentOptions.Image
        }
        
        mediaAttachmentPresenter?.attachmentTypes = mediaAttachmentOptions
        mediaAttachmentPresenter?.resultHandler = { [weak self](success: Bool, publishParameters: VPublishParameters?) -> Void in
            if let strongSelf = self {
                strongSelf.publishParameters = publishParameters
                strongSelf.mediaAttachmentPresenter = nil
                strongSelf.keyboardBar?.setSelectedThumbnail(publishParameters?.previewImage)
                strongSelf.keyboardBar?.startEditing()
            }
        }
    }
    
    func keyboardInputAccessoryViewWantsToClearMedia(inputAccessoryView: VKeyboardInputAccessoryView) {
        
        let shouldResumeEditing = inputAccessoryView.isEditing()
        inputAccessoryView.stopEditing()
        
        let alertController = VCommentAlertHelper.alertForConfirmDiscardMediaWithDelete({ () -> Void in
            self.publishParameters?.mediaToUploadURL = nil
            inputAccessoryView.setSelectedThumbnail(nil)
            if shouldResumeEditing {
                inputAccessoryView.startEditing()
            }
        }, cancel: { () -> Void in
            if shouldResumeEditing {
                inputAccessoryView.startEditing()
            }
        })
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func keyboardInputAccessoryViewDidBeginEditing(inpoutAccessoryView: VKeyboardInputAccessoryView) {
        // update insets
        
    }
    
    func keyboardInputAccessoryViewDidEndEditing(inpoutAccessoryView: VKeyboardInputAccessoryView) {
        // update insets
    }

}

extension CommentsViewController: UICollectionViewDataSource, CommentsDataSourceDelegate {
    
    // MARK: UICollectionViewDataSource
    
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
        
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifierForComment, forIndexPath: indexPath) as! VContentCommentsCell
        cell.dependencyManager = dependencyManager
        cell.comment = commentForIndexPath
        return cell as UICollectionViewCell
    }

    func commentsDataSourceDidUpdate(dataSource: CommentsDataSource) {
        collectionView.reloadData()
    }
    
    func commentsDataSourceDidUpdate(dataSource: CommentsDataSource, deepLinkinkId: NSNumber) {
        collectionView.reloadData()
    }
    
}

extension CommentsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var comment = sequence?.comments?[indexPath.item] as! VComment
        var size = VContentCommentsCell.sizeWithFullWidth(CGRectGetWidth(view.bounds),
            comment: comment,
            hasMedia: (comment.commentMediaType() != VCommentMediaType.NoMedia),
            dependencyManager: dependencyManager)
        return CGSizeMake(CGRectGetWidth(view.bounds), size.height)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollPaginator.scrollViewDidScroll(scrollView)
    }
    
}

extension CommentsViewController: VScrollPaginatorDelegate {
    
    func shouldLoadNextPage() {
        commentsDataSourceSwitcher.dataSource.loadNextPage()
    }
    
    func shouldLoadPreviousPage() {
        commentsDataSourceSwitcher.dataSource.loadPreviousPage()
    }
    
}
