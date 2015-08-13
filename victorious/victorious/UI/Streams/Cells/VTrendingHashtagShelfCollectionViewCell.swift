//
//  VTrendingHashtagShelfCollectionViewCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class VTrendingHashtagShelfCollectionViewCell: VTrendingShelfCollectionViewCell {

    private struct verticalConstraintConstants {
        static let separatorHeight : CGFloat = 4
        static let hashtagLabelVerticalSpace : CGFloat = 4
        static let titleTopVerticalSpace : CGFloat = 18
        static let titleToHashtagVerticalSpace : CGFloat = 17
        static let hashtagToCountsVerticalSpace : CGFloat = 8
        static let countsBottomVerticalSpace : CGFloat = 13
        static let collectionViewHeight : CGFloat = 100
        
        static let baseHeight = separatorHeight + hashtagLabelVerticalSpace + titleTopVerticalSpace + titleToHashtagVerticalSpace + hashtagToCountsVerticalSpace + countsBottomVerticalSpace + collectionViewHeight
    }
    
    @IBOutlet private weak var hashtagLabel: UILabel!
    @IBOutlet private weak var postCountLabel: UILabel!
    @IBOutlet private weak var followControl: VFollowControl!
    @IBOutlet private weak var hashtagLabelBackground: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private var hashtagLabelVerticalConstraints: [NSLayoutConstraint]!
    @IBOutlet private weak var titleTopVerticalSpace: NSLayoutConstraint!
    @IBOutlet private weak var titleToHashtagVerticalSpace: NSLayoutConstraint!
    @IBOutlet private weak var hashtagToCountsVerticalSpace: NSLayoutConstraint!
    @IBOutlet private weak var countsBottomVerticalSpace: NSLayoutConstraint!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var separatorHeightConstraint: NSLayoutConstraint!
    
    private static let titleText: NSString = NSLocalizedString("Fan Favorite", comment:"")
    
    private static let numberFormatter = VLargeNumberFormatter()
    
    override func onShelfSet()
    {
        super.onShelfSet()
        if let shelf = shelf as? HashtagShelf {
            hashtagLabel.text = VTrendingHashtagShelfCollectionViewCell.hashtagText(shelf)
            titleLabel.text = VTrendingHashtagShelfCollectionViewCell.titleText as String
            postCountLabel.text = VTrendingHashtagShelfCollectionViewCell.postCountText(shelf)
        }
    }
    
    override func onDependencyManagerSet() {
        super.onDependencyManagerSet()
        if let dependencyManager = dependencyManager {
            followControl.dependencyManager = dependencyManager
            
            titleLabel.font = dependencyManager.titleFont
            hashtagLabel.font = dependencyManager.hashtagFont
            postCountLabel.font = dependencyManager.postCountFont
            
            hashtagLabelBackground.backgroundColor = dependencyManager.colorForKey(VDependencyManagerAccentColorKey)
            separatorView.backgroundColor = dependencyManager.colorForKey(VDependencyManagerAccentColorKey)
            
            let textColor = dependencyManager.colorForKey(VDependencyManagerMainTextColorKey)
            titleLabel.textColor = textColor
            hashtagLabel.textColor = textColor
            postCountLabel.textColor = textColor
            
            dependencyManager.addBackgroundToBackgroundHost(self)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for constraint in hashtagLabelVerticalConstraints {
            constraint.constant = verticalConstraintConstants.hashtagLabelVerticalSpace
        }
        titleTopVerticalSpace.constant = verticalConstraintConstants.titleTopVerticalSpace
        titleToHashtagVerticalSpace.constant = verticalConstraintConstants.titleToHashtagVerticalSpace
        hashtagToCountsVerticalSpace.constant = verticalConstraintConstants.hashtagToCountsVerticalSpace
        countsBottomVerticalSpace.constant = verticalConstraintConstants.countsBottomVerticalSpace
        collectionViewHeightConstraint.constant = verticalConstraintConstants.collectionViewHeight
        separatorHeightConstraint.constant = verticalConstraintConstants.separatorHeight
    }
    
    override class func nibForCell() -> UINib {
        return UINib(nibName: "VTrendingHashtagShelfCollectionViewCell", bundle: nil)
    }

    class func desiredSize(collectionViewBounds bounds: CGRect, shelf: HashtagShelf, dependencyManager: VDependencyManager) -> CGSize {
        var height = verticalConstraintConstants.baseHeight
        
        //Add the height of the labels to find the entire height of the cell
        let titleHeight = VTrendingHashtagShelfCollectionViewCell.titleText.frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.titleFont]).height
        let hashtagHeight = VTrendingHashtagShelfCollectionViewCell.hashtagText(shelf).frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.hashtagFont]).height
        let postCountHeight = VTrendingHashtagShelfCollectionViewCell.postCountText(shelf).frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.postCountFont]).height
        
        height += titleHeight + hashtagHeight + postCountHeight
        
        return CGSizeMake(bounds.width, height)
    }
    
    private class func hashtagText(shelf: HashtagShelf) -> String {
        return "#" + shelf.hashtagTitle
    }
    
    private class func postCountText(shelf: HashtagShelf) -> String {
        return "In " + numberFormatter.stringForInteger(shelf.postsCount.integerValue) + " posts"
    }
}

private extension VDependencyManager {
    
    var titleFont : UIFont {
        return fontForKey(VDependencyManagerHeaderFontKey)
    }
    
    var hashtagFont : UIFont {
        return fontForKey(VDependencyManagerHeading2FontKey)
    }
    
    var postCountFont : UIFont {
        return fontForKey(VDependencyManagerLabel2FontKey)
    }
    
}

extension VTrendingHashtagShelfCollectionViewCell: VBackgroundContainer {
    
    func backgroundContainerView() -> UIView! {
        return self.contentView
    }
    
}
