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
@IBDesignable
class VNewProfileHeaderView: UICollectionReusableView, ConfigurableGridStreamHeader {
    fileprivate static let blurRadius = CGFloat(12)
    
    // MARK: - Initializing
    
    class func new(with dependencyManager: VDependencyManager) -> VNewProfileHeaderView {
        let view: VNewProfileHeaderView = VNewProfileHeaderView.v_fromNib()
        view.dependencyManager = dependencyManager
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.size = .large
        populateUserContent()
        
        NotificationCenter.default.addObserver(self, selector: #selector(currentUserDidUpdate), name: NSNotification.Name(rawValue: VCurrentUser.userDidUpdateNotificationKey), object: nil)
    }
    
    // MARK: - Models
    
    var user: UserModel? {
        didSet {
            populateUserContent()
        }
    }
    
    fileprivate static let observedUserProperties = ["name", "location", "tagline", "isVIPSubscriber", "likesGiven", "likesReceived", "pictureURL"]
    
    // MARK: - Views
    
    @IBOutlet fileprivate var contentContainerView: UIView!
    @IBOutlet fileprivate var loadingContainerView: UIView!
    @IBOutlet fileprivate var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet fileprivate var backgroundImageView: UIImageView!
    @IBOutlet fileprivate var displayNameLabel: UILabel!
    @IBOutlet fileprivate var usernameLabel: UILabel!
    @IBOutlet fileprivate var statsContainerView: UIView!
    @IBOutlet fileprivate var upvotesGivenValueLabel: UILabel!
    @IBOutlet fileprivate var upvotesGivenTitleLabel: UILabel!
    @IBOutlet fileprivate var upvotesReceivedValueLabel: UILabel!
    @IBOutlet fileprivate var upvotesReceivedTitleLabel: UILabel!
    @IBOutlet fileprivate var tierValueLabel: UILabel!
    @IBOutlet fileprivate var tierTitleLabel: UILabel!
    @IBOutlet fileprivate var locationLabel: UILabel!
    @IBOutlet fileprivate var taglineLabel: UILabel!
    @IBOutlet fileprivate var avatarView: AvatarView!
    
    // MARK: - Configuration
    
    weak var delegate: ConfigurableGridStreamHeaderDelegate?

    // MARK: - Dependency manager
    
    var dependencyManager: VDependencyManager? {
        didSet {
            if dependencyManager !== oldValue {
                applyDependencyManagerStyles()
                avatarView.isVIPEnabled = dependencyManager?.isVIPEnabled
            }
        }
    }
    
    fileprivate func applyDependencyManagerStyles() {
        let appearanceKey = user?.accessLevel.isCreator == true ? VNewProfileViewController.creatorAppearanceKey : VNewProfileViewController.userAppearanceKey
        let appearanceDependencyManager = dependencyManager?.childDependencyForKey(appearanceKey)
        
        tintColor = appearanceDependencyManager?.accentColor
        
        displayNameLabel.textColor = appearanceDependencyManager?.headerTextColor
        usernameLabel.textColor = appearanceDependencyManager?.statLabelTextColor
        upvotesGivenValueLabel.textColor = appearanceDependencyManager?.statValueTextColor
        upvotesGivenTitleLabel.textColor = appearanceDependencyManager?.statLabelTextColor
        upvotesReceivedValueLabel.textColor = appearanceDependencyManager?.statValueTextColor
        upvotesReceivedTitleLabel.textColor = appearanceDependencyManager?.statLabelTextColor
        tierValueLabel.textColor = appearanceDependencyManager?.statValueTextColor
        tierTitleLabel.textColor = appearanceDependencyManager?.statLabelTextColor
        locationLabel.textColor = appearanceDependencyManager?.infoTextColor
        taglineLabel.textColor = appearanceDependencyManager?.infoTextColor
        
        displayNameLabel.font = appearanceDependencyManager?.headerFont
        usernameLabel.font = appearanceDependencyManager?.statLabelFont
        upvotesGivenValueLabel.font = appearanceDependencyManager?.statValueFont
        upvotesGivenTitleLabel.font = appearanceDependencyManager?.statLabelFont
        upvotesReceivedValueLabel.font = appearanceDependencyManager?.statValueFont
        upvotesReceivedTitleLabel.font = appearanceDependencyManager?.statLabelFont
        tierValueLabel.font = appearanceDependencyManager?.statValueFont
        tierTitleLabel.font = appearanceDependencyManager?.statLabelFont
        locationLabel.font = appearanceDependencyManager?.infoFont
        taglineLabel.font = appearanceDependencyManager?.infoFont
        
        loadingSpinner.color = appearanceDependencyManager?.loadingSpinnerColor
        
        upvotesReceivedTitleLabel.text = appearanceDependencyManager?.receivedUpvotesTitle
        upvotesGivenTitleLabel.text = appearanceDependencyManager?.givenUpvotesTitle
        tierTitleLabel.text = appearanceDependencyManager?.tierTitle
    }
    
    // MARK: - Populating content
    
    fileprivate dynamic func currentUserDidUpdate() {
        user = VCurrentUser.user
        populateUserContent()
    }
    
    fileprivate func populateUserContent() {
        let userIsCreator = user?.accessLevel.isCreator == true
        
        statsContainerView.hidden = userIsCreator
        
        displayNameLabel.text = user?.displayName
        usernameLabel.text = user?.username
        locationLabel.text = user?.location
        taglineLabel.text = user?.tagline
        upvotesGivenValueLabel?.text = numberFormatter.stringForInteger(user?.likesGiven ?? 0)
        upvotesReceivedValueLabel?.text = numberFormatter.stringForInteger(user?.likesReceived ?? 0)
        
        let tier = user?.fanLoyalty?.tier
        let shouldDisplayTier = tier?.isEmpty == false
        tierValueLabel.text = tier
        tierTitleLabel.hidden = !shouldDisplayTier
        tierValueLabel.hidden = !shouldDisplayTier
        
        avatarView.user = user
        
        if let imageAsset = user?.previewImage(ofMinimumSize: backgroundImageView.frame.size) {
            backgroundImageView.getImageAsset(imageAsset, blurRadius: VNewProfileHeaderView.blurRadius) { [weak self] result in
                switch result {
                    case .success(let image): self?.backgroundImageView.image = image
                    case .failure(_): break
                }
                self?.backgroundImageView.alpha = 1.0
            }
        }
        else {
            self.backgroundImageView.alpha = 0.0
        }
        
        contentContainerView.hidden = user == nil
        loadingContainerView.hidden = user != nil
    }
    
    fileprivate let numberFormatter = VLargeNumberFormatter()
    
    // MARK: - ConfigurableGridStreamHeader
    
    func decorateHeader(_ dependencyManager: VDependencyManager, withWidth width: CGFloat, maxHeight: CGFloat, content: UserModel?, hasError: Bool) {
        // No error states for profiles
        self.user = content
    }
    
    func sizeForHeader(_ dependencyManager: VDependencyManager, withWidth width: CGFloat, maxHeight: CGFloat, content: UserModel?, hasError: Bool) -> CGSize {
        // No error states for profiles
        self.user = content
        
        setNeedsLayout()
        layoutIfNeeded()
        
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
