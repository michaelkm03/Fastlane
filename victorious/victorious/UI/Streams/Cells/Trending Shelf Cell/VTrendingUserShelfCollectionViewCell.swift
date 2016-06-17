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
protocol VTrendingUserShelfResponder {
    
    /// Sent when a user is selected from this shelf.
    ///
    /// - parameter user: The user that was selected.
    /// - parameter fromShelf: The shelf that the user was selected from.
    func trendingUserShelfSelected(user: VUser, fromShelf: UserShelf)
    
}

/// A shelf that displays a user and a set of his/her posts.
class VTrendingUserShelfCollectionViewCell: VTrendingShelfCollectionViewCell {
    
    private struct Constants {
        static let separatorHeight: CGFloat = 4
        static let titleTopVerticalSpace: CGFloat = 11
        static let followControlHeight: CGFloat = 28
        static let minimumTitleToContentVerticalSpace: CGFloat = 5
        static let userAvatarHeight: CGFloat = 36
        static let minimumBottomVerticalSpace: CGFloat = 13
        static let collectionViewHeight: CGFloat = 100
        static let usernameBottomToAvatarCenterSpace: CGFloat = 0
        static let countsTopToAvatarCenterSpace: CGFloat = 0
        
        static let baseHeight = separatorHeight + titleTopVerticalSpace + minimumTitleToContentVerticalSpace + minimumBottomVerticalSpace + collectionViewHeight
    }
    
    @IBOutlet private weak var usernameTextView: VTagSensitiveTextView!
    @IBOutlet private weak var userAvatarButton: VDefaultProfileButton!
    @IBOutlet private weak var postsCountLabel: UILabel!
    @IBOutlet private weak var titleTopVerticalSpaceConstraint: NSLayoutConstraint!
    @IBOutlet private var minimumBottomVerticalSpaceConstraints: [NSLayoutConstraint]!
    @IBOutlet private var minimumTitleToContentVerticalSpaceConstraints: [NSLayoutConstraint]!
    @IBOutlet private weak var separatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var followControlHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var userAvatarHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var usernameCenterConstraint: NSLayoutConstraint!
    @IBOutlet private weak var countsCenterConstraint: NSLayoutConstraint!
    
    private static let numberFormatter = VLargeNumberFormatter()
    
    //MARK: - Setters
    
    override var shelf: Shelf? {
        didSet {
            if oldValue == shelf {
                return
            }
            
            if let shelf = shelf as? UserShelf {
                titleLabel.text = shelf.title
                postsCountLabel.text = VTrendingUserShelfCollectionViewCell.getPostsCountText(shelf) as String
                if let oldValue = oldValue as? UserShelf {
                    KVOController.unobserve(oldValue.user)
                }
                KVOController.observe(shelf.user, keyPath: "isFollowedByMainUser", options: NSKeyValueObservingOptions.New, action: #selector(updateFollowControlState))
                userAvatarButton.user = shelf.user
                updateUsername()
            }
        }
    }
    
    override var dependencyManager: VDependencyManager? {
        didSet {
            if oldValue == dependencyManager {
                return
            }
            
            if let dependencyManager = dependencyManager {
                followControl?.dependencyManager = dependencyManager
                
                titleLabel.font = dependencyManager.titleFont
                postsCountLabel.font = dependencyManager.postsCountFont
                
                let accentColor = dependencyManager.accentColor
                separatorView.backgroundColor = accentColor
                userAvatarButton.dependencyManager = dependencyManager
                userAvatarButton.tintColor = accentColor
                userAvatarButton.addBorderWithWidth(2, andColor: accentColor)
                
                let textColor = dependencyManager.textColor
                titleLabel.textColor = textColor
                postsCountLabel.textColor = textColor
                
                updateUsername()
            }
        }
    }
    
    //MARK: - Getters
    
    private class func getUsernameText(shelf: UserShelf) -> String {
        return VTagStringFormatter.databaseFormattedStringFromUser(shelf.user) ?? ""
    }
    
    private class func getPostsCountText(shelf: UserShelf) -> String {
        var countsText = ""
        let hasFollowersCount = shelf.followersCount.integerValue != 0
        if shelf.postsCount.integerValue != 0 {
            let count = shelf.postsCount.integerValue
            let postsCount = numberFormatter.stringForInteger(count)
            let format = count == 1 ? NSLocalizedString("postsFormat", comment: "") : NSLocalizedString("postsPluralFormat", comment: "")
            countsText = NSString(format: format, postsCount) as String
            if hasFollowersCount {
                countsText += " • "
            }
        }
        if hasFollowersCount {
            let count = shelf.followersCount.integerValue
            let followersCount = numberFormatter.stringForInteger(count)
            let format = count == 1 ? NSLocalizedString("SuggestedFollowersSing", comment: "") : NSLocalizedString("SuggestedFollowersPlur", comment: "")
            countsText += NSString(format: format, followersCount) as String
        }
        return countsText
    }
    
    //MARK: - View management
    
    override class func nibForCell() -> UINib {
        return UINib(nibName: "VTrendingUserShelfCollectionViewCell", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for constraint in minimumTitleToContentVerticalSpaceConstraints {
            constraint.constant = Constants.minimumTitleToContentVerticalSpace
        }
        for constraint in minimumBottomVerticalSpaceConstraints {
            constraint.constant = Constants.minimumBottomVerticalSpace
        }
        separatorHeightConstraint.constant = Constants.separatorHeight
        titleTopVerticalSpaceConstraint.constant = Constants.titleTopVerticalSpace
        followControlHeightConstraint.constant = Constants.followControlHeight
        userAvatarHeightConstraint.constant = Constants.userAvatarHeight
        usernameCenterConstraint.constant = Constants.usernameBottomToAvatarCenterSpace
        countsCenterConstraint.constant = Constants.countsTopToAvatarCenterSpace
        usernameTextView.zeroInsets();
    }
    
    /// The optimal size for this cell.
    ///
    /// - parameter bounds: The bounds of the collection view containing this cell (minus any relevant insets)
    /// - parameter shelf: The shelf whose content will populate this cell
    /// - parameter dependencyManager: The dependency manager that will be used to style the cell
    ///
    /// :return: The optimal size for this cell.
    class func desiredSize(collectionViewBounds bounds: CGRect, shelf: UserShelf, dependencyManager: VDependencyManager) -> CGSize {
        var height = Constants.baseHeight
        
        //Add the height of the labels to find the entire height of the cell
        let titleHeight = shelf.title.frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.titleFont]).height
        let usernameHeight = VTrendingUserShelfCollectionViewCell.getUsernameText(shelf).frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.usernameFont]).height
        let postCountHeight = VTrendingUserShelfCollectionViewCell.getPostsCountText(shelf).frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.postsCountFont]).height
        
        let topContentHeight = max(titleHeight, Constants.followControlHeight)
        let topHalfOfUserHeight = max(usernameHeight, Constants.userAvatarHeight / 2)
        let bottomHalfOfUserHeight = max(postCountHeight, Constants.userAvatarHeight / 2)
        
        height += topContentHeight + topHalfOfUserHeight + bottomHalfOfUserHeight
        
        return CGSizeMake(bounds.width, height)
    }

    //MARK: - View updating
    
    override func updateFollowControlState() {
        if let shelf = shelf as? UserShelf,
            let isFollowed = shelf.user.isFollowedByMainUser?.boolValue {
            
            let controlState: VFollowControlState = isFollowed ? .Followed : .Unfollowed
            followControl?.setControlState(controlState, animated: true)
        }
    }
    
    private func updateUsername() {
        if let shelf = shelf as? UserShelf, let dependencyManager = dependencyManager {
            let formattedUsername = VTrendingUserShelfCollectionViewCell.getUsernameText(shelf)
            usernameTextView.setupWithDatabaseFormattedText(formattedUsername, tagAttributes: [NSFontAttributeName: dependencyManager.usernameFont, NSForegroundColorAttributeName: dependencyManager.textColor], defaultAttributes: [NSFontAttributeName: dependencyManager.usernameFont, NSForegroundColorAttributeName: UIColor.whiteColor()], andTagTapDelegate: self)
        }
    }
    
    //MARK: - Interaction response
    
    private func respondToUserTap() {
        let responder: VTrendingUserShelfResponder = typedResponder()
        if let shelf = shelf as? UserShelf {
            responder.trendingUserShelfSelected(shelf.user, fromShelf: shelf)
        }
        else {
            assertionFailure("VTrendingUserShelfCollectionViewCell had a user selected from an invalid shelf")
        }
    }
    
    @IBAction private func tappedFollowControl(followControl: VFollowControl) {
        // FollowUserOperation/FollowUserToggleOperation not supported in 5.0
    }
    
    @IBAction private func tappedAvatarButton(sender: VDefaultProfileButton) {
        respondToUserTap()
    }
    
}

extension VTrendingUserShelfCollectionViewCell: VTagSensitiveTextViewDelegate {
    
    func tagSensitiveTextView(tagSensitiveTextView: VTagSensitiveTextView, tappedTag tag: VTag) {
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