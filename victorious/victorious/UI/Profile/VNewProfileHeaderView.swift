//
//  VNewProfileHeaderView.swift
//  victorious
//
//  Created by Jarod Long on 4/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ConfigurableGridStreamHeaderDelegate: class {
    func shouldRefresh()
}

/// The collection header view used for `VNewProfileViewController`.
class VNewProfileHeaderView: UICollectionReusableView, ConfigurableGridStreamHeader {
    private static let blurRadius = CGFloat(12)
    
    // MARK: - Initializing
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> VNewProfileHeaderView {
        let view: VNewProfileHeaderView = VNewProfileHeaderView.v_fromNib()
        view.dependencyManager = dependencyManager
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.size = .large
        populateUserContent()
    }
    
    // MARK: - Models
    
    var user: VUser? {
        didSet {
            populateUserContent()
            
            if let oldValue = oldValue {
                KVOController.unobserve(oldValue)
            }
            
            if let user = user {
                KVOController.observe(user, keyPaths: VNewProfileHeaderView.observedUserProperties, options: [.New]) { [weak self] _, _, _ in
                    self?.populateUserContent()
                }
            }
        }
    }
    
    private static let observedUserProperties = ["name", "location", "tagline", "isVIPSubscriber", "likesGiven", "likesReceived", "pictureURL"]
    
    // MARK: - Views
    
    @IBOutlet private var contentContainerView: UIView!
    @IBOutlet private var loadingContainerView: UIView!
    @IBOutlet private var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet private var backgroundImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var vipIconImageView: UIImageView!
    @IBOutlet private var statsContainerView: UIView!
    @IBOutlet private var upvotesGivenValueLabel: UILabel!
    @IBOutlet private var upvotesGivenTitleLabel: UILabel!
    @IBOutlet private var upvotesReceivedValueLabel: UILabel!
    @IBOutlet private var upvotesReceivedTitleLabel: UILabel!
    @IBOutlet private var tierValueLabel: UILabel!
    @IBOutlet private var tierTitleLabel: UILabel!
    @IBOutlet private var locationLabel: UILabel!
    @IBOutlet private var taglineLabel: UILabel!
    @IBOutlet private var avatarView: AvatarView!
    
    // MARK: - Configuration
    
    weak var delegate: ConfigurableGridStreamHeaderDelegate?
    
    // MARK: - Constraints
    
    @IBOutlet private var profilePictureBottomSpacingConstraint: NSLayoutConstraint!
    
    // MARK: - Dependency manager
    
    var dependencyManager: VDependencyManager? {
        didSet {
            if dependencyManager !== oldValue {
                applyDependencyManagerStyles()
            }
        }
    }
    
    private func applyDependencyManagerStyles() {
        let appearanceKey = user?.isCreator == true ? VNewProfileViewController.creatorAppearanceKey : VNewProfileViewController.userAppearanceKey
        let appearanceDependencyManager = dependencyManager?.childDependencyForKey(appearanceKey)
        
        tintColor = appearanceDependencyManager?.accentColor
        
        nameLabel.textColor = appearanceDependencyManager?.headerTextColor
        upvotesGivenValueLabel.textColor = appearanceDependencyManager?.statValueTextColor
        upvotesGivenTitleLabel.textColor = appearanceDependencyManager?.statLabelTextColor
        upvotesReceivedValueLabel.textColor = appearanceDependencyManager?.statValueTextColor
        upvotesReceivedTitleLabel.textColor = appearanceDependencyManager?.statLabelTextColor
        tierValueLabel.textColor = appearanceDependencyManager?.statValueTextColor
        tierTitleLabel.textColor = appearanceDependencyManager?.statLabelTextColor
        locationLabel.textColor = appearanceDependencyManager?.infoTextColor
        taglineLabel.textColor = appearanceDependencyManager?.infoTextColor
        
        nameLabel.font = appearanceDependencyManager?.headerFont
        upvotesGivenValueLabel.font = appearanceDependencyManager?.statValueFont
        upvotesGivenTitleLabel.font = appearanceDependencyManager?.statLabelFont
        upvotesReceivedValueLabel.font = appearanceDependencyManager?.statValueFont
        upvotesReceivedTitleLabel.font = appearanceDependencyManager?.statLabelFont
        tierValueLabel.font = appearanceDependencyManager?.statValueFont
        tierTitleLabel.font = appearanceDependencyManager?.statLabelFont
        locationLabel.font = appearanceDependencyManager?.infoFont
        taglineLabel.font = appearanceDependencyManager?.infoFont
        
        vipIconImageView.image = appearanceDependencyManager?.vipIcon
        
        loadingSpinner.color = appearanceDependencyManager?.loadingSpinnerColor
        
        upvotesReceivedTitleLabel.text = appearanceDependencyManager?.receivedUpvotesTitle
        upvotesGivenTitleLabel.text = appearanceDependencyManager?.givenUpvotesTitle
        tierTitleLabel.text = appearanceDependencyManager?.tierTitle
    }
    
    // MARK: - Populating content
    
    private func populateUserContent() {
        let userIsCreator = user?.isCreator == true
        
        profilePictureBottomSpacingConstraint.active = userIsCreator
        statsContainerView.hidden = userIsCreator
        
        nameLabel.text = user?.displayName
        locationLabel.text = user?.location
        taglineLabel.text = user?.tagline
        vipIconImageView.hidden = user?.isVIPSubscriber?.boolValue != true
        upvotesGivenValueLabel?.text = numberFormatter.stringForInteger(user?.likesGiven ?? 0)
        upvotesReceivedValueLabel?.text = numberFormatter.stringForInteger(user?.likesReceived ?? 0)
        
        let tier = user?.tier
        let shouldDisplayTier = tier?.isEmpty == false
        tierValueLabel.text = tier
        tierTitleLabel.hidden = !shouldDisplayTier
        tierValueLabel.hidden = !shouldDisplayTier
        
        avatarView.user = user
        
        if let imageAsset = user?.previewImage(ofMinimumSize: backgroundImageView.frame.size) {
            backgroundImageView.getImageAsset(imageAsset, blurRadius: VNewProfileHeaderView.blurRadius) { [weak self] image, error in
                self?.backgroundImageView.image = image
                self?.backgroundImageView.alpha = 1.0
            }
        }
        else {
            self.backgroundImageView.alpha = 0.0
        }
        
        contentContainerView.hidden = user == nil
        loadingContainerView.hidden = user != nil
    }
    
    private let numberFormatter = VLargeNumberFormatter()
    
    // MARK: - ConfigurableGridStreamHeader
    
    func decorateHeader(dependencyManager: VDependencyManager, maxHeight: CGFloat, content: VUser?, hasError: Bool) {
        // No error states for profiles
        self.user = content
    }
    
    func sizeForHeader(dependencyManager: VDependencyManager, maxHeight: CGFloat, content: VUser?, hasError: Bool) -> CGSize {
        // No error states for profiles
        self.user = content
        
        setNeedsLayout()
        layoutIfNeeded()
        
        let width = CGRectGetWidth(UIScreen.mainScreen().bounds)
        let widthConstraint = v_addWidthConstraint(width)
        let height = systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        
        removeConstraint(widthConstraint)
        
        return CGSizeMake(width, height)
    }
    
    func gridStreamShouldRefresh() {
        delegate?.shouldRefresh()
    }
}

private extension VDependencyManager {
    var accentColor: UIColor? {
        return colorForKey(VDependencyManagerAccentColorKey)
    }
    
    var loadingSpinnerColor: UIColor? {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
    
    var headerTextColor: UIColor? {
        return colorForKey("color.text.header")
    }
    
    var statValueTextColor: UIColor? {
        return colorForKey(VDependencyManagerContentTextColorKey)
    }
    
    var statLabelTextColor: UIColor? {
        return colorForKey(VDependencyManagerSecondaryTextColorKey)
    }
    
    var infoTextColor: UIColor? {
        return colorForKey("color.text.paragraph")
    }
    
    var headerFont: UIFont? {
        return fontForKey(VDependencyManagerHeaderFontKey)
    }
    
    var statValueFont: UIFont? {
        return fontForKey(VDependencyManagerHeading2FontKey)
    }
    
    var statLabelFont: UIFont? {
        return fontForKey(VDependencyManagerLabel2FontKey)
    }
    
    var infoFont: UIFont? {
        return fontForKey(VDependencyManagerParagraphFontKey)
    }
    
    var vipIcon: UIImage? {
        return imageForKey("vipIcon")?.imageWithRenderingMode(.AlwaysTemplate)
    }
    
    var receivedUpvotesTitle: String? {
        return stringForKey("upvoted.text")
    }
    
    var givenUpvotesTitle: String? {
        return stringForKey("upvotes.text")
    }
    
    var tierTitle: String? {
        return stringForKey("status.text")
    }
}
