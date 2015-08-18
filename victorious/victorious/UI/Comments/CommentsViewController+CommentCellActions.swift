//
//  CommentsViewController+CommentCellActions.swift
//  victorious
//
//  Created by Michael Sena on 8/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension CommentsViewController: VTagSensitiveTextViewDelegate, VSwipeViewControllerDelegate, VCommentCellUtilitiesDelegate, VEditCommentViewControllerDelegate {
    
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
            self.shouldHideNavBar = false
            self.navigationController?.pushViewController(profileViewController, animated: true)
        }
        else {
            var justHashTagText = (tag.displayString.string as NSString).substringFromIndex(1)
            var hashtagViewController = dependencyManager.hashtagStreamWithHashtag(justHashTagText)
            self.shouldHideNavBar = false
            self.navigationController?.pushViewController(hashtagViewController, animated: true)
        }
    }
    
    // MARK: - VCommentCellUtilitiesDelegate
    
    func commentRemoved(comment: VComment) {
    }
    
    func commentRemoved(comment: VComment, atIndex index: Int) {
        collectionView.performBatchUpdates({ () -> Void in
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
                if let commentCell = cell as? VContentCommentsCell {
                    if commentCell.comment.remoteId == comment.remoteId {
                        // Set updated comment on cell
                        commentCell.comment = comment
                        
                        // Try to reload the cell without reloading the whole section
                        var indexPathToInvalidate = self.collectionView.indexPathForCell(commentCell)
                        if let indexPathToInvalidate = indexPathToInvalidate {
                            self.collectionView.performBatchUpdates({ () -> Void in
                                self.collectionView.reloadItemsAtIndexPaths([indexPathToInvalidate])
                                }, completion: nil)
                        }
                        else {
                            self.collectionView.reloadSections(NSIndexSet(index: 0))
                        }
                    }
                }
            }
        })
    }
    
}

