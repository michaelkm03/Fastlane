//
//  VTrendingHashtagShelfCollectionViewCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit
import KVOController

/// Classes that conform to this protocol will receive messages when
/// a hashtag is selected from this shelf.
protocol VTrendingHashtagShelfResponder {
    /// Sent when a user is selected from this shelf.
    ///
    /// - parameter user: The user that was selected.
    /// - parameter fromShelf: The shelf that the hashtag was selected from.
    func trendingHashtagShelfSelected(hashtag: String, fromShelf: HashtagShelf)
}

/// A shelf that displays a hashtag and its posts.
class VTrendingHashtagShelfCollectionViewCell: VTrendingShelfCollectionViewCell {
    
    private struct Constants {
        static let separatorHeight: CGFloat = 4
        static let hashtagTextViewVerticalSpace: CGFloat = 4
        static let titleTopVerticalSpace: CGFloat = 11
        static let titleToHashtagVerticalSpace: CGFloat = 11
        static let hashtagToCountsVerticalSpace: CGFloat = 8
        static let countsBottomVerticalSpace: CGFloat = 13
        static let collectionViewHeight: CGFloat = 100
        
        static let baseHeight = separatorHeight + hashtagTextViewVerticalSpace + titleTopVerticalSpace + titleToHashtagVerticalSpace + hashtagToCountsVerticalSpace + countsBottomVerticalSpace + collectionViewHeight
    }
    
    @IBOutlet private weak var hashtagTextView: VHashTagTextView!
    @IBOutlet private weak var postsCountLabel: UILabel!
    @IBOutlet private weak var hashtagLabelBackground: UIView!
    @IBOutlet private var hashtagLabelVerticalConstraints: [NSLayoutConstraint]!
    @IBOutlet private weak var titleTopVerticalSpace: NSLayoutConstraint!
    @IBOutlet private weak var titleToHashtagVerticalSpace: NSLayoutConstraint!
    @IBOutlet private weak var hashtagToCountsVerticalSpace: NSLayoutConstraint!
    @IBOutlet private weak var countsBottomVerticalSpace: NSLayoutConstraint!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var separatorHeightConstraint: NSLayoutConstraint!
    
    private static let numberFormatter = VLargeNumberFormatter()
    
    private var followingCallComplete = false
    
    //MARK: - Setters
    
    override var shelf: Shelf? {
        didSet {
            if oldValue == shelf {
                return
            }
            
            if let shelf = shelf as? HashtagShelf {
                hashtagTextView.text = VTrendingHashtagShelfCollectionViewCell.getHashtagText(shelf)
                titleLabel.text = shelf.title
                postsCountLabel.text = VTrendingHashtagShelfCollectionViewCell.getPostsCountText(shelf)
                
                // Check if we are following this hashtag and register it if so
                VObjectManager.sharedManager().mainUser?.addFollowedHashtags([shelf.hashtagObject], checkFollowingFlag: true)
                
                updateFollowControlState()
            }
        }
    }
    
    override var dependencyManager: VDependencyManager? {
        didSet {
            if oldValue == dependencyManager {
                return
            }
            
            if let dependencyManager = dependencyManager {
                titleLabel.font = dependencyManager.titleFont
                hashtagTextView.font = dependencyManager.hashtagFont
                postsCountLabel.font = dependencyManager.postsCountFont
                
                let accentColor = dependencyManager.accentColor
                hashtagLabelBackground.backgroundColor = accentColor
                separatorView.backgroundColor = accentColor
                
                let textColor = dependencyManager.textColor
                titleLabel.textColor = textColor
                hashtagTextView.textColor = textColor
                postsCountLabel.textColor = textColor
                
                hashtagTextView.dependencyManager = dependencyManager
                hashtagTextView.updateForLinkTextForegroundColor(UIColor.whiteColor())
            }
        }
    }
    
    //MARK: - Getters
    
    private class func getHashtagText(shelf: HashtagShelf) -> String {
        return "#" + shelf.hashtagObject.tag
    }
    
    private class func getPostsCountText(shelf: HashtagShelf) -> String {
        let count = shelf.postsCount.integerValue
        let hashtagCount = numberFormatter.stringForInteger(shelf.postsCount.integerValue)
        let format = count == 1 ? NSLocalizedString("HashtagPostsCountFormat", comment: "") : NSLocalizedString("HashtagPostsCountPluralFormat", comment: "")
        return NSString(format: format, hashtagCount) as String
    }
    
    //MARK: - View management
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for constraint in hashtagLabelVerticalConstraints {
            constraint.constant = Constants.hashtagTextViewVerticalSpace
        }
        titleTopVerticalSpace.constant = Constants.titleTopVerticalSpace
        titleToHashtagVerticalSpace.constant = Constants.titleToHashtagVerticalSpace
        hashtagToCountsVerticalSpace.constant = Constants.hashtagToCountsVerticalSpace
        countsBottomVerticalSpace.constant = Constants.countsBottomVerticalSpace
        collectionViewHeightConstraint.constant = Constants.collectionViewHeight
        separatorHeightConstraint.constant = Constants.separatorHeight
        
        hashtagTextView.textContainer.lineFragmentPadding = 0
        hashtagTextView.textContainerInset = UIEdgeInsetsZero
        hashtagTextView.contentInset = UIEdgeInsetsZero
        hashtagTextView.linkDelegate = self
        
        KVOController.observe(VObjectManager.sharedManager().mainUser, keyPath: "hashtags", options:NSKeyValueObservingOptions.Old, action: Selector("handleUserHashtagsArrayChange:"))
    }
    
    override class func nibForCell() -> UINib {
        return UINib(nibName: "VTrendingHashtagShelfCollectionViewCell", bundle: nil)
    }
    
    ///Updates the state of the follow control if an appropriate change has occurred
    func handleUserHashtagsArrayChange(changeInfo: [NSObject : AnyObject]?) {
        guard shouldUpdateFollowControlState(forChangeInfo: changeInfo) else {
            return
        }
        updateFollowControlState()
    }
    
    override func updateFollowControlState() {
        guard let shelf = shelf as? HashtagShelf else {
            return
        }
        var controlState: VFollowControlState = .Unfollowed
        if let mainUser = VObjectManager.sharedManager().mainUser
            where mainUser.isFollowingHashtagString(shelf.hashtagObject.tag) {
            controlState = .Followed
        }
        followControl.setControlState(controlState, animated: true)
    }
    
    private func shouldUpdateFollowControlState(forChangeInfo changeInfo: [NSObject : AnyObject]?) -> Bool {
        guard let changeInfo = changeInfo where followingCallComplete else { return false }
        if let oldValue = changeInfo[NSKeyValueChangeOldKey] as? NSOrderedSet {
            if let hashtags = VObjectManager.sharedManager().mainUser?.hashtags
                where oldValue.isEqualToOrderedSet(hashtags) {
                    return false // Old hashtags and new hashtags are identical, don't update
            }
        }
        else if VObjectManager.sharedManager().mainUser?.hashtags == nil {
            return false // Hashtags was nil and continues to be nil, don't update
        }
        return true
    }

    /// The optimal size for this cell.
    ///
    /// - parameter bounds: The bounds of the collection view containing this cell (minus any relevant insets)
    /// - parameter shelf: The shelf whose content will populate this cell
    /// - parameter dependencyManager: The dependency manager that will be used to style the cell
    ///
    /// :return: The optimal size for this cell.
    class func desiredSize(collectionViewBounds bounds: CGRect, shelf: HashtagShelf, dependencyManager: VDependencyManager) -> CGSize {
        var height = Constants.baseHeight
        
        //Add the height of the labels to find the entire height of the cell
        let title = shelf.title
        let titleHeight = title.frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.titleFont]).height
        
        let hashtagText = VTrendingHashtagShelfCollectionViewCell.getHashtagText(shelf)
        let hashtagHeight = hashtagText.frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.hashtagFont]).height
        
        let postsCountText = VTrendingHashtagShelfCollectionViewCell.getPostsCountText(shelf)
        let postsCountHeight = postsCountText.frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.postsCountFont]).height
        
        height += titleHeight + hashtagHeight + postsCountHeight
        
        return CGSizeMake(bounds.width, height)
    }
    
    //MARK: - Interaction response
    
    @IBAction private func tappedFollowControl(followControl: VFollowControl) {
        let target: VHashtagResponder = typedResponder()
        switch followControl.controlState {
        case .Unfollowed:
            if let shelf = shelf as? HashtagShelf {
                followingCallComplete = false
                followControl.setControlState(VFollowControlState.Loading, animated: true)
                target.followHashtag(shelf.hashtagObject.tag,
                    successBlock: { [weak self] ( _:[AnyObject] ) in
                        guard let strongSelf = self else {
                            return
                        }
                        strongSelf.followingCallComplete = true
                        strongSelf.updateFollowControlState()
                    },
                    failureBlock: { [weak self] (NSError) in
                        guard let strongSelf = self else {
                            return
                        }
                        strongSelf.followingCallComplete = true
                        strongSelf.updateFollowControlState()
                    })
            }
            else {
                assertionFailure("The VTrendingHashtagShelfCollectionViewCell attempted to follow non-HashtagShelf shelf")
            }
        case .Followed:
            if let shelf = shelf as? HashtagShelf {
                followingCallComplete = false
                followControl.setControlState(VFollowControlState.Loading, animated: true)
                target.unfollowHashtag(shelf.hashtagObject.tag,
                    successBlock: { [weak self] ( _:[AnyObject] ) in
                        guard let strongSelf = self else {
                            return
                        }
                        strongSelf.followingCallComplete = true
                        strongSelf.updateFollowControlState()
                    },
                    failureBlock: { [weak self] (NSError) in
                        guard let strongSelf = self else {
                            return
                        }
                        strongSelf.followingCallComplete = true
                        strongSelf.updateFollowControlState()
                    })
            }
            else {
                assertionFailure("The VTrendingHashtagShelfCollectionViewCell attempted to unfollow non-HashtagShelf shelf")
            }
        case .Loading:
            break
        }
    }
}

extension VTrendingHashtagShelfCollectionViewCell: CCHLinkTextViewDelegate {
    
    func linkTextView(linkTextView: CCHLinkTextView!, didTapLinkWithValue value: AnyObject!) {
        let responder: VTrendingHashtagShelfResponder = typedResponder()
        if let hashtag = value as? String, let shelf = shelf as? HashtagShelf {
            responder.trendingHashtagShelfSelected(hashtag, fromShelf: shelf)
        }
        else
        {
            assertionFailure("VTrendingHashtagShelfCollectionViewCell needs a VHashtagSelectionResponder up it's responder chain to send messages to.")
        }
    }
    
}

private extension VDependencyManager {
    
    var titleFont: UIFont {
        return fontForKey(VDependencyManagerHeaderFontKey)
    }
    
    var hashtagFont: UIFont {
        return fontForKey(VDependencyManagerHeading2FontKey)
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
