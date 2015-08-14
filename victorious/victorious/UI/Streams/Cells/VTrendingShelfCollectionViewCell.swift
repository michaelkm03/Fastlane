//
//  VTrendingShelfCollectionViewCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

///A shelf that displays a list of trending content along with some metadata.
///Utilize subclasses for implementations.
class VTrendingShelfCollectionViewCell: VBaseCollectionViewCell {
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
            self.onShelfSet()
        }
    }
    
    var dependencyManager : VDependencyManager? {
        didSet {
            self.onDependencyManagerSet()
        }
    }
    
    ///Override in subclasses to make adjustments based on the dependency manager
    func onDependencyManagerSet() {
        if let dependencyManager = dependencyManager {
            followControl.dependencyManager = dependencyManager
            dependencyManager.addBackgroundToBackgroundHost(self)
        }
    }
    
    ///Override in subclasses to make adjustments based on the shelf
    func onShelfSet() {
        if let streamItems = shelf?.stream?.streamItems {
            if let streamItems = streamItems.array as? [VStreamItem] {
                for (index, streamItem) in enumerate(streamItems) {
                    let isShowMoreCell = index == streamItems.count - 1
                    collectionView.registerClass(VTrendingShelfContentCollectionViewCell.self, forCellWithReuseIdentifier: VTrendingShelfContentCollectionViewCell.reuseIdentifierForStreamItem(streamItem, asShowMore: isShowMoreCell, baseIdentifier: nil, dependencyManager: dependencyManager))
                }
            }
        }
        updateFollowControlState()
        self.collectionView.reloadData()
    }
    
    ///Override in subclasses to update the follow button at the proper times
    func updateFollowControlState() {}
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension VTrendingShelfCollectionViewCell : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let streamItems = shelf?.stream?.streamItems.array as? [VStreamItem] {
            let streamItem = streamItems[indexPath.row]
            let isShowMoreCell = indexPath.row == streamItems.count - 1
            let identifier = VTrendingShelfContentCollectionViewCell.reuseIdentifierForStreamItem(streamItem, asShowMore: isShowMoreCell, baseIdentifier: nil, dependencyManager: dependencyManager)
            let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! UICollectionViewCell
            if let cell = cell as? VTrendingShelfContentCollectionViewCell {
                cell.streamItem = streamItem
                cell.dependencyManager = dependencyManager
                if isShowMoreCell {
                    cell.showOverlay = true
                }
            }
            return cell
        }
        assertionFailure("VTrendingShelfCollectionViewCell was asked to display an object that isn't a stream item.")
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let streamItems = shelf?.stream?.streamItems {
            return streamItems.count
        }
        return 0
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
}

extension VTrendingShelfCollectionViewCell : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let streamItem = shelf?.stream?.streamItems[indexPath.row] as? VStreamItem, responder = nextResponder()?.targetForAction(Selector("navigateTo:fromShelf:"), withSender: nil) as? VShelfStreamItemSelectionResponder {
            responder.navigateTo(streamItem, fromShelf: shelf!)
        }
        else {
            assertionFailure("VTrendingShelfCollectionViewCell needs a VShelfStreamItemSelectionResponder up it's responder chain to send messages to.")
        }
    }
}

extension VTrendingShelfCollectionViewCell : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 15, 15, 15)
    }
}


extension VTrendingShelfCollectionViewCell: VBackgroundContainer {
    func backgroundContainerView() -> UIView! {
        return contentView
    }
}
