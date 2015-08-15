//
//  VTrendingUserShelfCollectionViewCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// Classes that conform to this protocol will receive messages when
/// a user is selected from this shelf.
@objc protocol VTrendingUserShelfResponder {
    
    /// Sent when a user is selected from this shelf.
    ///
    /// :param: user The user that was selected.
    /// :param: fromShelf The shelf that the user was selected from.
    func trendingUserShelfSelected(user: VUser, fromShelf: UserShelf)
    
}

/// A shelf that displays a user and a set of his/her posts.
class VTrendingUserShelfCollectionViewCell: VTrendingShelfCollectionViewCell {
    
    private struct VerticalConstraintConstants {
        static let separatorHeight: CGFloat = 4
        static let minimumTopVerticalSpace: CGFloat = 11
        static let followControlHeight: CGFloat = 28
        static let minimumTitleToContentVerticalSpace: CGFloat = 5
        static let userAvatarHeight: CGFloat = 36
        static let minimumBottomVerticalSpace: CGFloat = 13
        static let collectionViewHeight: CGFloat = 100
        static let usernameBottomToAvatarCenterSpace: CGFloat = 0
        static let countsTopToAvatarCenterSpace: CGFloat = 0
        
        static let baseHeight = separatorHeight + minimumTopVerticalSpace + minimumTitleToContentVerticalSpace + minimumBottomVerticalSpace + collectionViewHeight
    }
    
    @IBOutlet private weak var usernameTextView: VTagSensitiveTextView!
    @IBOutlet private weak var userAvatarButton: VDefaultProfileButton!
    @IBOutlet private weak var postsCountLabel: UILabel!
    @IBOutlet private var minimumTopVerticalSpaceConstraints: [NSLayoutConstraint]!
    @IBOutlet private var minimumBottomVerticalSpaceConstraints: [NSLayoutConstraint]!
    @IBOutlet private var minimumTitleToContentVerticalSpaceConstraints: [NSLayoutConstraint]!
    @IBOutlet private weak var separatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var followControlHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var userAvatarHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var usernameCenterConstraint: NSLayoutConstraint!
    @IBOutlet private weak var countsCenterConstraint: NSLayoutConstraint!
    
    private static let titleText: NSString = NSLocalizedString("Trending User", comment:"")
    
    //MARK: - Setters
    
    override func onShelfSet() {
        super.onShelfSet()
        if let shelf = shelf as? UserShelf {
            titleLabel.text = VTrendingUserShelfCollectionViewCell.titleText as String
            postsCountLabel.text = VTrendingUserShelfCollectionViewCell.getPostsCountText(shelf) as String
            userAvatarButton.setProfileImageURL(NSURL(string: shelf.user.pictureUrl), forState: UIControlState.Normal)
            updateUsername()
        }
    }
    
    override func onDependencyManagerSet() {
        super.onDependencyManagerSet()
        if let dependencyManager = dependencyManager {
            followControl.dependencyManager = dependencyManager
            
            titleLabel.font = dependencyManager.titleFont
            postsCountLabel.font = dependencyManager.postsCountFont
            
            let accentColor = dependencyManager.accentColor
            separatorView.backgroundColor = accentColor
            userAvatarButton.tintColor = accentColor
            userAvatarButton.addBorderWithWidth(2, andColor: accentColor)
            
            let textColor = dependencyManager.textColor
            titleLabel.textColor = textColor
            postsCountLabel.textColor = textColor
            
            updateUsername()
        }
    }
    
    //MARK: - Getters
    
    private class func getUsernameText(shelf: UserShelf) -> String {
        return shelf.user.name
    }
    
    private class func getPostsCountText(shelf: UserShelf) -> String {
        var countsText = ""
        let hasFollowersCount = shelf.followersCount.integerValue != 0
        if shelf.postsCount.integerValue != 0 {
            countsText = shelf.postsCount.stringValue + " " + NSLocalizedString("posts", comment: "")
            if hasFollowersCount {
                countsText += " • "
            }
        }
        if hasFollowersCount {
            countsText += shelf.followersCount.stringValue + " " + NSLocalizedString("followers", comment: "")
        }
        return countsText
    }
    
    //MARK: - View management
    
    override class func nibForCell() -> UINib {
        return UINib(nibName: "VTrendingUserShelfCollectionViewCell", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userAvatarButton.setup()
        for constraint in minimumTopVerticalSpaceConstraints {
            constraint.constant = VerticalConstraintConstants.minimumTopVerticalSpace
        }
        for constraint in minimumTitleToContentVerticalSpaceConstraints {
            constraint.constant = VerticalConstraintConstants.minimumTitleToContentVerticalSpace
        }
        for constraint in minimumBottomVerticalSpaceConstraints {
            constraint.constant = VerticalConstraintConstants.minimumBottomVerticalSpace
        }
        separatorHeightConstraint.constant = VerticalConstraintConstants.separatorHeight
        followControlHeightConstraint.constant = VerticalConstraintConstants.followControlHeight
        userAvatarHeightConstraint.constant = VerticalConstraintConstants.userAvatarHeight
        usernameCenterConstraint.constant = VerticalConstraintConstants.usernameBottomToAvatarCenterSpace
        countsCenterConstraint.constant = VerticalConstraintConstants.countsTopToAvatarCenterSpace
        usernameTextView.zeroInsets();
    }
    
    /// The optimal size for this cell.
    ///
    /// :param: bounds The bounds of the collection view containing this cell (minus any relevant insets)
    /// :param: shelf The shelf whose content will populate this cell
    /// :param: dependencyManager The dependency manager that will be used to style the cell
    ///
    /// :return: The optimal size for this cell.
    class func desiredSize(collectionViewBounds bounds: CGRect, shelf: UserShelf, dependencyManager: VDependencyManager) -> CGSize {
        var height = VerticalConstraintConstants.baseHeight
        
        //Add the height of the labels to find the entire height of the cell
        let titleHeight = VTrendingUserShelfCollectionViewCell.titleText.frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.titleFont]).height
        let usernameHeight = VTrendingUserShelfCollectionViewCell.getUsernameText(shelf).frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.usernameFont]).height
        let postCountHeight = VTrendingUserShelfCollectionViewCell.getPostsCountText(shelf).frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.postsCountFont]).height
        
        let topContentHeight = max(titleHeight, VerticalConstraintConstants.followControlHeight)
        let topHalfOfUserHeight = max(usernameHeight, VerticalConstraintConstants.userAvatarHeight / 2)
        let bottomHalfOfUserHeight = max(postCountHeight, VerticalConstraintConstants.userAvatarHeight / 2)
        
        height += topContentHeight + topHalfOfUserHeight + bottomHalfOfUserHeight
        
        return CGSizeMake(bounds.width, height)
    }

    //MARK: - View updating
    
    override func updateFollowControlState() {
        if let shelf = shelf as? UserShelf {
            var controlState: VFollowControlState = .Unfollowed
            if shelf.user.isFollowedByMainUser.boolValue {
                controlState = .Followed
            }
            followControl.setControlState(controlState, animated: true)
        }
    }
    
    private func updateUsername() {
        if let shelf = shelf as? UserShelf, let dependencyManager = dependencyManager {
            let formattedUsername = VTagStringFormatter.databaseFormattedStringFromUser(shelf.user)
            usernameTextView.setupWithDatabaseFormattedText(formattedUsername, tagAttributes: [NSFontAttributeName : dependencyManager.usernameFont, NSForegroundColorAttributeName : dependencyManager.textColor], defaultAttributes: [NSFontAttributeName : dependencyManager.usernameFont, NSForegroundColorAttributeName : UIColor.whiteColor()], andTagTapDelegate: self)
        }
    }
    
    //MARK: - Interaction response
    
    private func respondToUserTap() {
        if let responder = nextResponder()?.targetForAction(Selector("trendingUserShelfSelected:fromShelf:"), withSender: self) as? VTrendingUserShelfResponder, let shelf = shelf as? UserShelf {
            responder.trendingUserShelfSelected(shelf.user, fromShelf: shelf)
        }
        else {
            assertionFailure("VTrendingUserShelfCollectionViewCell needs a VTrendingUserShelfResponder up it's responder chain to send messages to.")
        }
    }
    
    @IBAction private func tappedFollowControl(followControl: VFollowControl) {
        switch followControl.controlState {
        case .Unfollowed:
            if let target: VFollowResponder = nextResponder()?.targetForAction(Selector("followUser:withAuthorizedBlock:andCompletion:fromViewController:withScreenName:"), withSender: followControl) as? VFollowResponder,
                let shelf = shelf as? UserShelf {
                    followControl.setControlState(.Loading, animated: true)
                    target.followUser(shelf.user, withAuthorizedBlock: { () -> Void in
                        followControl.controlState = .Loading
                        },
                        andCompletion: { [weak self] (user: VUser) -> Void in
                            if let strongSelf = self {
                                strongSelf.updateFollowControlState()
                            }
                        }, fromViewController: nil, withScreenName: VFollowSourceScreenTrendingUserShelf)
            }
            else {
                assertionFailure("The VTrendingUserShelfCollectionViewCell needs a follow responder further up its responder chain.")
            }
        case .Followed:
            if let target: VFollowResponder = nextResponder()?.targetForAction(Selector("unfollowUser:withAuthorizedBlock:andCompletion:fromViewController:withScreenName:"), withSender: followControl) as? VFollowResponder, let shelf = shelf as? UserShelf {
                followControl.setControlState(VFollowControlState.Loading, animated: true)
                target.unfollowUser(shelf.user, withAuthorizedBlock: { () -> Void in
                    followControl.controlState = VFollowControlState.Loading
                    },
                    andCompletion: { [weak self] (user: VUser) -> Void in
                        if let strongSelf = self {
                            strongSelf.updateFollowControlState()
                        }
                    }, fromViewController: nil, withScreenName: VFollowSourceScreenTrendingUserShelf)
            }
            else {
                assertionFailure("The VTrendingUserShelfCollectionViewCell needs a follow responder further up its responder chain.")
            }
        default:()
        }
    }
    
    @IBAction private func tappedAvatarButton(sender: VDefaultProfileButton) {
        respondToUserTap()
    }
    
}

extension VTrendingUserShelfCollectionViewCell : VTagSensitiveTextViewDelegate {
    
    func tagSensitiveTextView(tagSensitiveTextView: VTagSensitiveTextView!, tappedTag tag: VTag!) {
        respondToUserTap()
    }
    
}

private extension VDependencyManager {
    
    var titleFont: UIFont {
        return fontForKey(VDependencyManagerHeaderFontKey)
    }
    
    var usernameFont: UIFont {
        return fontForKey(VDependencyManagerHeading4FontKey)
    }
    
    var postsCountFont: UIFont {
        return fontForKey(VDependencyManagerLabel2FontKey)
    }
    
    var accentColor: UIColor {
        return colorForKey(VDependencyManagerAccentColorKey)
    }
    
    var textColor: UIColor {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
    
}
