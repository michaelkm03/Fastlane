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

class CommentsViewController: UIViewController, VKeyboardInputAccessoryViewDelegate {
    
    private var dependencyManager : VDependencyManager!
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> CommentsViewController {
        let vc: CommentsViewController = self.fromStoryboardInitialViewController()
        vc.dependencyManager = dependencyManager
        return vc
    }
    
    private var sequence: VSequence? {
        didSet {
            if let sequence = sequence {
                dataSource = CommentsCollectionViewDataSource(sequence: sequence, dependencyManager: dependencyManager)
            }
        }
    }
    private var dataSource: CommentsCollectionViewDataSource?
    
    // MARK: Outlets
    
    @IBOutlet var collectionView: VInputAccessoryCollectionView!
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardBar = VKeyboardInputAccessoryView.defaultInputAccessoryViewWithDependencyManager(dependencyManager)
        keyboardBar?.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        collectionView.dataSource = dataSource
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // FIXME: This may not handle lightboxes well
        self.becomeFirstResponder()
        self.rootNavigationController().setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.accessoryView = keyboardBar
        collectionView.becomeFirstResponder()
        keyboardBar?.becomeFirstResponder()
        
        
        // FIXME: This should be factored out into a separate class
        VObjectManager.sharedManager().loadCommentsOnSequence(sequence,
            pageType: VPageType.First,
            successBlock: { (operation : NSOperation?, result : AnyObject?, resultObjects : [AnyObject]) -> Void in
                self.collectionView.reloadData()
            },
            failBlock: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // FIXME: This may not handle lightboxes well
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
    
    // MARK: VKeyboardInputAccessoryViewDelegate
    
    func pressedSendOnKeyboardInputAccessoryView(inputAccessoryView: VKeyboardInputAccessoryView!) {
        
    }
    
    func keyboardInputAccessoryView(inputAccessoryView: VKeyboardInputAccessoryView!, selectedAttachmentType attachmentType: VKeyboardBarAttachmentType) {
        
    }
    
    func keyboardInputAccessoryViewWantsToClearMedia(inputAccessoryView: VKeyboardInputAccessoryView!) {
        
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
    
}

class CommentsCollectionViewDataSource : NSObject, UICollectionViewDataSource {
    
    let mySequence : VSequence
    let dependencyManager: VDependencyManager
    var registeredCommentReuseIdentifiers = Set<String>()
    
    init(sequence: VSequence, dependencyManager: VDependencyManager) {
        mySequence = sequence
        self.dependencyManager = dependencyManager
        super.init()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let comments = mySequence.comments {
            return comments.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let commentForIndexPath = mySequence.comments?.array[indexPath.item] as! VComment
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
}

