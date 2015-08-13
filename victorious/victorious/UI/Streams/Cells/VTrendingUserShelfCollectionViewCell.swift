//
//  VTrendingUserShelfCollectionViewCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class VTrendingUserShelfCollectionViewCell: VTrendingShelfCollectionViewCell {

    
    //Warning: Constraint constants need to change to reflect mock
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
        
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var profileImageButton: VDefaultProfileButton!
    @IBOutlet private weak var postCountLabel: UILabel!
    @IBOutlet private weak var followControl: VFollowControl!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private var minimumTopSpaceVerticalConstraints: [NSLayoutConstraint]!
    @IBOutlet private var minimumBottomSpaceVerticalConstraints: [NSLayoutConstraint]!
    @IBOutlet private var minimumTitleToUserSpaceVerticalConstraints: [NSLayoutConstraint]!
    @IBOutlet private weak var interLabelVerticalSpace: NSLayoutConstraint!
    @IBOutlet private weak var separatorHeightConstraint: NSLayoutConstraint!
    
    private static let titleText: NSString = NSLocalizedString("Trending User", comment:"")
    
    override func onShelfSet()
    {
        super.onShelfSet()
        /*if let sequence = streamItem as? VSequence {
            userDetailsLabel.text = "5K followers • 109 Posts"
            usernameLabel.text = sequence.user?.name
            profileImageButton.setProfileImageURL(NSURL(string: sequence.displayOriginalPoster().pictureUrl), forState: UIControlState.Normal)
        }*/
    }
    
    override func onDependencyManagerSet() {
        super.onDependencyManagerSet()
        if let dependencyManager = dependencyManager {
            followControl.dependencyManager = dependencyManager
            
            profileImageButton.tintColor = dependencyManager.colorForKey(VDependencyManagerLinkColorKey)
            usernameLabel.font = dependencyManager.fontForKey(VDependencyManagerLabel1FontKey)
            postCountLabel.font = dependencyManager.fontForKey(VDependencyManagerLabel3FontKey)
            
        }
    }
    
    override class func nibForCell() -> UINib {
        return UINib(nibName: "VTrendingUserShelfCollectionViewCell", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageButton.setup()
    }
    
    class func desiredSize(collectionViewBounds bounds: CGRect, shelf: UserShelf, dependencyManager: VDependencyManager) -> CGSize {
        var height = verticalConstraintConstants.baseHeight
        
        //Add the height of the labels to find the entire height of the cell
        let titleHeight = VTrendingUserShelfCollectionViewCell.titleText.frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.titleFont]).height
        let hashtagHeight = VTrendingUserShelfCollectionViewCell.hashtagText(shelf).frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.hashtagFont]).height
        let postCountHeight = VTrendingUserShelfCollectionViewCell.postCountText(shelf).frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.postCountFont]).height
        
        height += titleHeight + hashtagHeight + postCountHeight
        
        return CGSizeMake(bounds.width, height)
    }
    
    private class func hashtagText(shelf: UserShelf) -> String {
        return shelf.user.name
    }
    
    private class func postCountText(shelf: UserShelf) -> String {
        return shelf.postsCount.stringValue + " posts   " + shelf.followersCount.stringValue + " followers"
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

extension VTrendingUserShelfCollectionViewCell: VBackgroundContainer {
    
    func backgroundContainerView() -> UIView! {
        return self.contentView
    }
    
}
