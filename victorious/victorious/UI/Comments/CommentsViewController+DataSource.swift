//
//  CommentsViewController+DataSource.swift
//  victorious
//
//  Created by Michael Sena on 8/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation


extension CommentsViewController: UICollectionViewDataSource, CommentsDataSourceDelegate {
    
    // MARK: - UICollectionViewDataSource + CommentsDataSourceDelegate
    
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
        cell.commentAndMediaView.textView.tagTapDelegate = self
        cell.swipeViewController.controllerDelegate = self
        cell.commentsUtilitiesDelegate = self
        cell.onUserProfileTapped = { [weak self] in
            if let strongSelf = self {
                var profileViewController = strongSelf.dependencyManager.userProfileViewControllerWithUser(commentForIndexPath.user)
                strongSelf.shouldHideNavBar = false
                strongSelf.rootNavigationController()?.pushViewController(profileViewController, animated: true)
            }
        }
        return cell as UICollectionViewCell
    }
    
    func commentsDataSourceDidUpdate(dataSource: CommentsDataSource) {
        collectionView.reloadData()
        dispatch_after(0.1, {
            self.focusHelper?.updateFocus()
            self.updateInsetForKeyboardBarState()
        })
        
    }
    
    func commentsDataSourceDidUpdate(dataSource: CommentsDataSource, deepLinkinkId: NSNumber) {
        collectionView.reloadData()
        focusHelper?.updateFocus()
        updateInsetForKeyboardBarState()
    }
    
}


