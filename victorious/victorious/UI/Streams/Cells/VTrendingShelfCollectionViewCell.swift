//
//  VTrendingShelfCollectionViewCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// A shelf that displays a list of trending content along with some metadata.
/// Utilize subclasses for implementations.
class VTrendingShelfCollectionViewCell: VBaseCollectionViewCell {
    
    private let kLoggedInChangedNotification = "com.getvictorious.LoggedInChangedNotification"
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var followControl: VFollowControl! {
        didSet {
            followControl.tintUnselectedImage = true
        }
    }
    
    var shelf: VShelf? {
        didSet {
            if shelf == oldValue {
                return
            }
            
            self.onShelfSet()
        }
    }
    
    var dependencyManager: VDependencyManager? {
        didSet {
            if dependencyManager == oldValue {
                return
            }
            
            self.onDependencyManagerSet()
        }
    }
    
    /// Override in subclasses to make adjustments based on the dependency manager
    func onDependencyManagerSet() {
        if let dependencyManager = dependencyManager {
            followControl.dependencyManager = dependencyManager
            dependencyManager.addBackgroundToBackgroundHost(self)
        }
    }
    
    /// Override in subclasses to make adjustments based on the shelf
    func onShelfSet() {
        if let items = shelf?.stream?.streamItems,
            let streamItems = items.array as? [VStreamItem] {
                for (index, streamItem) in enumerate(streamItems) {
                    if index == streamItems.count - 1 {
                        collectionView.registerClass(VTrendingShelfContentSeeAllCell.self, forCellWithReuseIdentifier: VTrendingShelfContentSeeAllCell.reuseIdentifierForStreamItem(streamItem, baseIdentifier: nil, dependencyManager: dependencyManager))
                    }
                    else {
                        collectionView.registerClass(VShelfContentCollectionViewCell.self, forCellWithReuseIdentifier: VShelfContentCollectionViewCell.reuseIdentifierForStreamItem(streamItem, baseIdentifier: nil, dependencyManager: dependencyManager))
                    }
                }
        }
        updateFollowControlState()
        self.collectionView.reloadData()
    }
    
    /// Override in subclasses to update the follow button at the proper times
    func updateFollowControlState() {}
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("loginStatusDidChange"), name: kLoggedInChangedNotification, object: VObjectManager.sharedManager())
    }
    
    /// Nils out shelf to respond to changes in login, should not be called except in response to a login change.
    func loginStatusDidChange() {
        shelf = nil
    }
    
}

extension VTrendingShelfCollectionViewCell : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let streamItems = shelf?.stream?.streamItems.array as? [VStreamItem] {
            let streamItem = streamItems[indexPath.row]
            let isShowMoreCell = indexPath.row == streamItems.count - 1
            let T = isShowMoreCell ? VTrendingShelfContentSeeAllCell.self : VShelfContentCollectionViewCell.self
            let identifier = T.reuseIdentifierForStreamItem(streamItem, baseIdentifier: nil, dependencyManager: dependencyManager)
            let cell: VShelfContentCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! VShelfContentCollectionViewCell
            cell.streamItem = streamItem
            cell.dependencyManager = dependencyManager
            return cell
        }
        assertionFailure("VTrendingShelfCollectionViewCell was asked to display an object that isn't a stream item.")
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shelf?.stream?.streamItems?.count ?? 0
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
}

extension VTrendingShelfCollectionViewCell : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let responder: VShelfStreamItemSelectionResponder = typedResponder()
        if let stream = shelf?.stream, let streamItem = stream.streamItems[indexPath.row] as? VStreamItem {
            var itemToNavigateTo: VStreamItem? = streamItem
            if indexPath.row == stream.streamItems.count - 1 {
                itemToNavigateTo = nil
            }
            if let shelf = shelf {
                responder.navigateTo(itemToNavigateTo, fromShelf: shelf)
                return
            }
        }
        assertionFailure("VTrendingShelfCollectionViewCell needs a VShelfStreamItemSelectionResponder up it's responder chain to send messages to.")
    }
    
}

extension VTrendingShelfCollectionViewCell : UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 11, 11, 11)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(89, 89)
    }
    
}


extension VTrendingShelfCollectionViewCell: VBackgroundContainer {
    
    func backgroundContainerView() -> UIView! {
        return contentView
    }
    
}
