//
//  VListPlaylistShelfCollectionViewCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class VListPlaylistShelfCollectionViewCell: VListShelfCollectionViewCell {
    
    private static let kTitleText: NSString = NSLocalizedString("FEATURED PLAYLIST", comment:"")
    
    override var dependencyManager: VDependencyManager? {
        didSet {
            if !VListShelfCollectionViewCell.needsUpdate(fromDependencyManager: oldValue, toDependencyManager: dependencyManager) { return }

            if let dependencyManager = dependencyManager {
                separatorView.backgroundColor = dependencyManager.accentColor
                
                titleLabel.font = dependencyManager.titleFont
                detailLabel.font = dependencyManager.detailFont
                
                titleLabel.textColor = dependencyManager.textColor
                detailLabel.textColor = dependencyManager.textColor
            }
        }
    }
    
    //MARK: -View management
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = VListPlaylistShelfCollectionViewCell.kTitleText as? String
    }

    override class func desiredSize(collectionViewBounds: CGRect, shelf: ListShelf, dependencyManager: VDependencyManager) -> CGSize {
        var size = super.desiredSize(collectionViewBounds, shelf: shelf, dependencyManager: dependencyManager)
        size.height += kTitleText.frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.titleFont]).height
        size.height += NSString(string: shelf.caption).frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.detailFont]).height
        size.height += Constants.detailToCollectionViewVerticalSpace
        return size
    }

    override class func nibForCell() -> UINib {
        return UINib(nibName: "VListPlaylistShelfCollectionViewCell", bundle: nil)
    }
}

extension VListPlaylistShelfCollectionViewCell : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let responder: VShelfStreamItemSelectionResponder = typedResponder()
        if let shelf = shelf {
            var itemToNavigateTo: VStreamItem?
            if indexPath.row != 0, let streamItem = shelf.stream.streamItems[indexPath.row - 1] as? VStreamItem {
                itemToNavigateTo = streamItem
            }
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
