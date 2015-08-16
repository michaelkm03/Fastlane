//
//  VListRecentShelfCollectionViewCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class VListRecentShelfCollectionViewCell: VListShelfCollectionViewCell {
    
    @IBOutlet weak var seeAllButton: UIButton!
    
    @IBOutlet weak var seeAllButtonHeightConstraint: NSLayoutConstraint!
    
    private static let kTitleText: NSString = NSLocalizedString("RECENT POSTS", comment:"")
    private static let kSeeAllButtonText: NSString = NSLocalizedString("See all", comment:"")
    private static let kSeeAllChevron = UIImage(named: "chevron_icon")!
    
    override func onDependencyManagerSet() {
        super.onDependencyManagerSet()
        if let dependencyManager = dependencyManager {
            separatorView.backgroundColor = dependencyManager.accentColor
            
            titleLabel.font = dependencyManager.titleFont
            detailLabel.font = dependencyManager.detailFont
            seeAllButton.titleLabel?.font = dependencyManager.seeAllFont

            titleLabel.textColor = dependencyManager.textColor
            detailLabel.textColor = dependencyManager.textColor
            seeAllButton.tintColor = dependencyManager.textColor
        }
    }
    
    //MARK: - View management
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = VListRecentShelfCollectionViewCell.kTitleText as? String
        seeAllButton.setTitle(VListRecentShelfCollectionViewCell.kSeeAllButtonText as? String, forState: .Normal)
        seeAllButton.setImage(VListRecentShelfCollectionViewCell.kSeeAllChevron, forState: .Normal)
    }

    override class func desiredSize(collectionViewBounds: CGRect, shelf:VShelf, dependencyManager: VDependencyManager) -> CGSize {
        var size = super.desiredSize(collectionViewBounds, shelf: shelf, dependencyManager: dependencyManager)
        
        let titleHeight = kTitleText.frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.titleFont]).height
        let seeAllButtonHeight = max(kSeeAllButtonText.frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.seeAllFont]).height, kSeeAllChevron.size.height)
        size.height += max(titleHeight, seeAllButtonHeight)
        
        if let name = shelf.stream?.name {
            size.height += NSString(string: name).frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.detailFont]).height
            size.height += Constants.detailToCollectionViewVerticalSpace
        }
        
        return size
    }

    override class func nibForCell() -> UINib {
        return UINib(nibName: "VListRecentShelfCollectionViewCell", bundle: nil)
    }
    
}

extension VListRecentShelfCollectionViewCell : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let responder: VShelfStreamItemSelectionResponder = typedResponder()
        if let stream = shelf?.stream, let streamItem = stream.streamItems[indexPath.row] as? VStreamItem {
            responder.navigateTo(streamItem, fromShelf: shelf!)
        }
        else {
            assertionFailure("VListRecentShelfCollectionViewCell needs a VShelfStreamItemSelectionResponder up it's responder chain to send messages to.")
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
