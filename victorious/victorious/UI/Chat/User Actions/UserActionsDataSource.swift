//
//  UserActionsDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 3/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

enum UserAction: String {
    case Reply, Block, ViewProfile, Dismiss
}

class UserActionsDataSource: NSObject, UICollectionViewDataSource {
    
    let user: VUser
    let availableActions: [UserAction]
    
    init(user: VUser) {
        self.user = user
        self.availableActions = [ .Reply, .Block ]
    }
    
    func actionForIndexPath(indexPath: NSIndexPath) -> UserAction? {
        switch indexPath.section {
        case 0:
            return .ViewProfile
        case 1:
            return availableActions[ indexPath.row ]
        default:
            return nil
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return availableActions.count
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func registerCellsWithCollectionView( collectionView: UICollectionView ) {
        let headerIdentifier =  "UserActionsHeaderCell"
        let headerNib = UINib(nibName:headerIdentifier, bundle: NSBundle(forClass: UserActionsHeaderCell.self) )
        collectionView.registerNib(headerNib, forCellWithReuseIdentifier: headerIdentifier)
        
        let actionIdentifier =  "UserActionCell"
        let actionNib = UINib(nibName:actionIdentifier, bundle: NSBundle(forClass: UserActionCell.self) )
        collectionView.registerNib(actionNib, forCellWithReuseIdentifier: actionIdentifier)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: collectionView.bounds.width, height: 120.0 )
        default:
            return CGSize(width: collectionView.bounds.width, height: 50.0 )
        }
    }
    
    func collectionView( collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath ) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let identifier = "UserActionsHeaderCell"
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! UserActionsHeaderCell
            cell.viewData = UserActionsHeaderCell.ViewData(
                username: user.name ?? "",
                avatarImageURL: NSURL(v_string: user.pictureUrl)!
            )
            return cell
        default:
            let identifier = "UserActionCell"
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! UserActionCell
            let action = availableActions[indexPath.row]
            cell.viewData = UserActionCell.ViewData(action: action.rawValue)
            return cell
        }
    }
}