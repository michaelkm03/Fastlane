//
//  VListPlaylistShelfCollectionViewCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// A list shelf cell that displays a stylized label on top of the stream's preview image
/// along with the first 7 pieces of content from a recent shelf.
class VListPlaylistShelfCollectionViewCell: VListShelfCollectionViewCell {
    
    override var shelf: Shelf? {
        didSet {
            if oldValue == shelf {
                return
            }
            
            if let shelf = shelf {
                collectionView.registerClass(VListShelfContentCoverCell.self, forCellWithReuseIdentifier: VListShelfContentCoverCell.reuseIdentifierForStreamItem(shelf, baseIdentifier: nil, dependencyManager: dependencyManager))
            }
        }
    }
    
    //MARK: -View management

    override class func desiredSize(collectionViewBounds: CGRect, shelf: ListShelf, dependencyManager: VDependencyManager) -> CGSize {
        var size = super.desiredSize(collectionViewBounds, shelf: shelf, dependencyManager: dependencyManager)
        size.height += shelf.title.frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.titleFont]).height
        size.height += NSString(string: shelf.caption).frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.detailFont]).height
        size.height += Constants.detailToCollectionViewVerticalSpace
        return size
    }

    override class func nibForCell() -> UINib {
        return UINib(nibName: "VListPlaylistShelfCollectionViewCell", bundle: nil)
    }
}

extension VListPlaylistShelfCollectionViewCell { // UICollectionViewDataSource methods
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let shelf = shelf, let streamItems = shelf.streamItems.array as? [VStreamItem] {
            var streamItem: VStreamItem = shelf
            var T = VShelfContentCollectionViewCell.self
            if indexPath.row == 0 {
                T = VListShelfContentCoverCell.self
            }
            else {
                streamItem = streamItems[indexPath.row - 1]
            }
            let identifier = T.reuseIdentifierForStreamItem(streamItem, baseIdentifier: nil, dependencyManager: dependencyManager)
            if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as? VShelfContentCollectionViewCell {
                cell.streamItem = streamItem
                cell.dependencyManager = dependencyManager
                if let cell = cell as? VListShelfContentCoverCell {
                    cell.overlayText = shelf.name
                }
                return cell
            }
        }
        assertionFailure("VListPlaylistShelfCollectionViewCell was asked to display an object that isn't a stream item.")
        failureCellFactory.registerNoContentCellWithCollectionView(collectionView)
        return failureCellFactory.noContentCellForCollectionView(collectionView, atIndexPath: indexPath)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let streamItems = shelf?.streamItems {
            //Max number of items at maxItemsCount to avoid showing erroneous UI if the backend returns an unexpected number of items.
            let numberOfItems = streamItems.count + 1
            return min(numberOfItems, VListShelfCollectionViewCell.Constants.maxItemsCount)
        }
        return 0
    }
    
}

extension VListPlaylistShelfCollectionViewCell { // UICollectionViewDelegate methods
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let shelf = shelf {
            let responder: VShelfStreamItemSelectionResponder = typedResponder()
            let itemToNavigateTo: VStreamItem? = {
                if indexPath.row != 0, let streamItem = shelf.streamItems[indexPath.row - 1] as? VStreamItem {
                     return streamItem
                }
                return nil
            }()
            responder.navigateTo(itemToNavigateTo, fromShelf: shelf)
        }
    }
    
}

private extension VDependencyManager {
    
    var titleFont: UIFont {
        return fontForKey(VDependencyManagerHeaderFontKey)
    }
    
    var detailFont: UIFont {
        return fontForKey(VDependencyManagerLabel3FontKey)
    }
    
    var textColor: UIColor {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
    
    var accentColor: UIColor {
        return colorForKey(VDependencyManagerAccentColorKey)
    }

}
