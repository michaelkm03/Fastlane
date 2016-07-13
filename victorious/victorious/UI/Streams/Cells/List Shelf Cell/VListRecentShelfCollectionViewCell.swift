//
//  VListRecentShelfCollectionViewCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// A list collection view cell that displays a "see all" button along with the
/// first 7 pieces of content from a recent shelf.
class VListRecentShelfCollectionViewCell: VListShelfCollectionViewCell {
    
    @IBOutlet private weak var seeAllButton: UIButton!
    
    @IBOutlet private weak var seeAllButtonHeightConstraint: NSLayoutConstraint!
    
    private static let kSeeAllButtonText: NSString = NSLocalizedString("See all", comment:"")
    private static let kSeeAllChevron = UIImage(named: "chevron_icon")!
    
    @IBAction private func pressedSeeAllButton(sender: VRightSideIconButton) {
        if let shelf = shelf {
            self.navigateTo(nil, fromShelf: shelf)
        }
    }
    
    override var dependencyManager: VDependencyManager? {
        didSet {
            if oldValue == dependencyManager {
                return
            }
            
            if let dependencyManager = dependencyManager {
                seeAllButton.titleLabel?.font = dependencyManager.seeAllFont
                seeAllButton.tintColor = dependencyManager.textColor
            }
        }
    }
    
    // MARK: - View management
    
    override func awakeFromNib() {
        super.awakeFromNib()
        seeAllButton.setTitle(VListRecentShelfCollectionViewCell.kSeeAllButtonText as String, forState: .Normal)
        seeAllButton.setImage(VListRecentShelfCollectionViewCell.kSeeAllChevron, forState: .Normal)
    }

    override class func desiredSize(collectionViewBounds: CGRect, shelf: ListShelf, dependencyManager: VDependencyManager) -> CGSize {
        var size = super.desiredSize(collectionViewBounds, shelf: shelf, dependencyManager: dependencyManager)
        
        let titleHeight = shelf.title.frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.titleFont]).height
        let seeAllButtonHeight = max(kSeeAllButtonText.frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.seeAllFont]).height, kSeeAllChevron.size.height)
        size.height += max(titleHeight, seeAllButtonHeight)
        
        size.height += NSString(string: shelf.caption).frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.detailFont]).height
        
        return size
    }

    override class func nibForCell() -> UINib {
        return UINib(nibName: "VListRecentShelfCollectionViewCell", bundle: nil)
    }
    
    private func navigateTo(streamItem: VStreamItem?, fromShelf: Shelf) {
        let responder: VShelfStreamItemSelectionResponder = typedResponder()
        responder.navigateTo(streamItem, fromShelf: fromShelf)
    }
    
}

extension VListRecentShelfCollectionViewCell { // UICollectionViewDataSource methods
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let shelf = shelf {
            let streamItem = shelf.streamItems[indexPath.row]
            let identifier = VShelfContentCollectionViewCell.reuseIdentifierForStreamItem(streamItem, baseIdentifier: nil, dependencyManager: dependencyManager)
            if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as? VShelfContentCollectionViewCell {
                cell.streamItem = streamItem
                cell.dependencyManager = dependencyManager
                if let cell = cell as? VListShelfContentCoverCell {
                    cell.overlayText = shelf.name
                }
                return cell
            }
        }
        assertionFailure("VListRecentShelfCollectionViewCell was asked to display an object that isn't a stream item.")
        failureCellFactory.registerNoContentCellWithCollectionView(collectionView)
        return failureCellFactory.noContentCellForCollectionView(collectionView, atIndexPath: indexPath)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let streamItems = shelf?.streamItems {
            //Max number of items at maxItemsCount to avoid showing erroneous UI if the backend returns an unexpected number of items.
            let numberOfItems = streamItems.count
            return min(numberOfItems, VListShelfCollectionViewCell.Constants.maxItemsCount)
        }
        return 0
    }
    
}

extension VListRecentShelfCollectionViewCell { // TrackableShelf methods
    
    override func streamItemAt(indexPath indexPath: NSIndexPath) -> VStreamItem? {
        if let shelf = shelf where indexPath.row < shelf.streamItems.count {
            return shelf.streamItems[indexPath.row]
        }
        return nil
    }
    
}

extension VListRecentShelfCollectionViewCell { // UICollectionViewDelegate methods
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let shelf = shelf {
            let streamItem = shelf.streamItems[indexPath.row]
            self.navigateTo(streamItem, fromShelf: shelf)
        }
        else {
            assertionFailure("A cell with an unexpected index path was selected from the VListRecentShelfCollectionViewCell")
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
    
    var seeAllFont: UIFont {
        return fontForKey(VDependencyManagerLabel2FontKey)
    }
    
    var textColor: UIColor {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
    
    var accentColor: UIColor {
        return colorForKey(VDependencyManagerAccentColorKey)
    }

}
