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
    // MARK: - Constants
    
    private static let shadowRadius: CGFloat = 2.0
    private static let shadowOpacity: Float = 0.5
    private static let userProfilePictureWidth: CGFloat = 80.0
    private static let creatorProfilePictureWidth: CGFloat = 90.0
    
    weak var delegate: ConfigurableGridStreamHeaderDelegate?
    
    // MARK: - Initializing
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> VNewProfileHeaderView {
        let view: VNewProfileHeaderView = VNewProfileHeaderView.v_fromNib()
        view.dependencyManager = dependencyManager
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profilePictureShadowView.layer.shadowColor = UIColor.blackColor().CGColor
        profilePictureShadowView.layer.shadowRadius = VNewProfileHeaderView.shadowRadius
        profilePictureShadowView.layer.shadowOpacity = VNewProfileHeaderView.shadowOpacity
        profilePictureShadowView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        
        populateUserContent()
    }
    
    // MARK: - Models
    
    var user: VUser? {
        didSet {
            if user == oldValue {
                return
            }
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
    @IBOutlet private var likesGivenValueLabel: UILabel!
    @IBOutlet private var likesGivenTitleLabel: UILabel!
    @IBOutlet private var likesReceivedValueLabel: UILabel!
    @IBOutlet private var likesReceivedTitleLabel: UILabel!
    @IBOutlet private var tierValueLabel: UILabel!
    @IBOutlet private var tierTitleLabel: UILabel!
    @IBOutlet private var locationLabel: UILabel!
    @IBOutlet private var taglineLabel: UILabel!
    @IBOutlet private var profilePictureView: UIImageView!
    @IBOutlet private var profilePictureShadowView: UIView!
    
    // MARK: - Constraints
    
    @IBOutlet private var profilePictureWidthConstraint: NSLayoutConstraint!
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
        likesGivenValueLabel.textColor = appearanceDependencyManager?.statValueTextColor
        likesGivenTitleLabel.textColor = appearanceDependencyManager?.statLabelTextColor
        likesReceivedValueLabel.textColor = appearanceDependencyManager?.statValueTextColor
        likesReceivedTitleLabel.textColor = appearanceDependencyManager?.statLabelTextColor
        tierValueLabel.textColor = appearanceDependencyManager?.statValueTextColor
        tierTitleLabel.textColor = appearanceDependencyManager?.statLabelTextColor
        locationLabel.textColor = appearanceDependencyManager?.infoTextColor
        taglineLabel.textColor = appearanceDependencyManager?.infoTextColor
        
        nameLabel.font = appearanceDependencyManager?.headerFont
        likesGivenValueLabel.font = appearanceDependencyManager?.statValueFont
        likesGivenTitleLabel.font = appearanceDependencyManager?.statLabelFont
        likesReceivedValueLabel.font = appearanceDependencyManager?.statValueFont
        likesReceivedTitleLabel.font = appearanceDependencyManager?.statLabelFont
        tierValueLabel.font = appearanceDependencyManager?.statValueFont
        tierTitleLabel.font = appearanceDependencyManager?.statLabelFont
        locationLabel.font = appearanceDependencyManager?.infoFont
        taglineLabel.font = appearanceDependencyManager?.infoFont
        
        vipIconImageView.image = appearanceDependencyManager?.vipIcon
        
        loadingSpinner.color = appearanceDependencyManager?.loadingSpinnerColor
    }
    
    // MARK: - Populating content
    
    private func populateUserContent() {
        let userIsCreator = user?.isCreator == true
        
        if userIsCreator {
            profilePictureWidthConstraint.constant = VNewProfileHeaderView.creatorProfilePictureWidth
        } else {
            profilePictureWidthConstraint.constant = VNewProfileHeaderView.userProfilePictureWidth
        }
        
        profilePictureBottomSpacingConstraint.active = userIsCreator
        statsContainerView.hidden = userIsCreator
        
        nameLabel.text = user?.name
        locationLabel.text = user?.location
        taglineLabel.text = user?.tagline
        vipIconImageView.hidden = user?.isVIPSubscriber?.boolValue != true
        likesGivenValueLabel?.text = numberFormatter.stringForInteger(user?.likesGiven ?? 0)
        likesReceivedValueLabel?.text = numberFormatter.stringForInteger(user?.likesReceived ?? 0)
        
        let tier = user?.tier
        let shouldDisplayTier = tier?.isEmpty == false
        tierValueLabel.text = tier
        tierTitleLabel.hidden = !shouldDisplayTier
        tierValueLabel.hidden = !shouldDisplayTier
        
        let placeholderImage = UIImage(named: "profile_full")
        let pictureURL = user?.pictureURL(ofMinimumSize: profilePictureView.frame.size)
        profilePictureView.sd_setImageWithURL(pictureURL, placeholderImage: placeholderImage)
        
        if let backgroundPictureURL = user?.pictureURL(ofMinimumSize: backgroundImageView.frame.size) {
            backgroundImageView.applyBlurToImageURL(backgroundPictureURL, withRadius: 12.0) { [weak self] in
                self?.backgroundImageView.alpha = 1.0
            }
        }
        
        contentContainerView.hidden = user == nil
        loadingContainerView.hidden = user != nil
    }
    
    private let numberFormatter = VLargeNumberFormatter()
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateProfilePictureShadowPathIfNeeded()
        
        profilePictureView.layer.cornerRadius = profilePictureView.frame.size.v_roundCornerRadius
    }
    
    // MARK: - Shadows
    
    private var shadowBounds: CGRect?
    
    private func updateProfilePictureShadowPathIfNeeded() {
        let newShadowBounds = profilePictureShadowView.bounds

        if newShadowBounds != shadowBounds {
            shadowBounds = newShadowBounds
            profilePictureShadowView.layer.shadowPath = UIBezierPath(ovalInRect: newShadowBounds).CGPath
        }
    }
    
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
}
