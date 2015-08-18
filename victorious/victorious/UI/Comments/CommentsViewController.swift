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

}

class CommentsViewController: UIViewController, VKeyboardInputAccessoryViewDelegate {

    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> CommentsViewController {
        let vc: CommentsViewController = self.fromStoryboardInitialViewController()
        vc.dependencyManager = dependencyManager
        return vc
    }
    
    var dependencyManager : VDependencyManager! {
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
    
    let commentsDataSourceSwitcher = CommentsDataSourceSwitchter()
    var registeredCommentReuseIdentifiers = Set<String>()
    private let scrollPaginator = VScrollPaginator()
    var authorizedAction : VAuthorizedAction!
    var publishParameters: VPublishParameters?
    var mediaAttachmentPresenter: VMediaAttachmentPresenter?
    var focusHelper : VCollectionViewStreamFocusHelper?
    var shouldHideNavBar = true
    var modalTransitioningDelegate = VTransitionDelegate(transition: VSimpleModalTransition())
    
    // MARK: Outlets
    
    @IBOutlet var collectionView: VInputAccessoryCollectionView!
    @IBOutlet var imageView: UIImageView!
    
    // MARK: UIViewController
    
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
        rootNavigationController().setNavigationBarHidden(false, animated: true)
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
        shouldHideNavBar = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.resignFirstResponder()
        
        if shouldHideNavBar {
            self.rootNavigationController().setNavigationBarHidden(true, animated: true)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        focusHelper?.endFocusOnAllCells()
    }
    
    // MARK:  Keyboard Bar
    
    var keyboardBar : VKeyboardInputAccessoryView? {
        didSet {
            if let keyboardBar = keyboardBar {
                keyboardBar.setTranslatesAutoresizingMaskIntoConstraints(false)
                keyboardBar.delegate = self
                keyboardBar.textStorageDelegate = self
            }
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override var inputAccessoryView: UIView! {
        get {
            return keyboardBar
        }
    }

    func updateInsetForKeyboardBarState() {
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
    
}

extension CommentsViewController: UICollectionViewDelegateFlowLayout {
    
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
            return CGSize(width: CGRectGetWidth(view.bounds), height: size.height)
        }
        return CGSize.zeroSize
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
