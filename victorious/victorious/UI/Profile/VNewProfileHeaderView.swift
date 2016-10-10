//
//  VNewProfileHeaderView.swift
//  victorious
//
//  Created by Jarod Long on 4/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

protocol ConfigurableGridStreamHeaderDelegate: class {
    func shouldRefresh()
}

/// The collection header view used for `VNewProfileViewController`.
@IBDesignable
class VNewProfileHeaderView: UICollectionReusableView, ConfigurableGridStreamHeader {
    private static let blurRadius = CGFloat(12)
    
    // MARK: - Initializing
    
    class func new(withDependencyManager dependencyManager: VDependencyManager) -> VNewProfileHeaderView {
        let view: VNewProfileHeaderView = VNewProfileHeaderView.v_fromNib()
        view.dependencyManager = dependencyManager
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.size = .large
        populateUserContent()
        
        NotificationCenter.default.addObserver(self, selector: #selector(currentUserDidUpdate), name: NSNotification.Name(rawValue: VCurrentUser.userDidUpdateNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(currentUserDidChange), name: NSNotification.Name.loggedInChanged, object: nil)
    }
    
    // MARK: - Models
    
    var user: UserModel? {
        didSet {
            populateUserContent()
        }
    }
    
    private static let observedUserProperties = ["name", "location", "tagline", "isVIPSubscriber", "likesGiven", "likesReceived", "pictureURL"]
    
    // MARK: - Views
    
    @IBOutlet private var contentContainerView: UIView!
    @IBOutlet private var loadingContainerView: UIView!
    @IBOutlet private var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet private var backgroundImageView: UIImageView!
    @IBOutlet private var displayNameLabel: UILabel!
    @IBOutlet private var usernameLabel: UILabel!
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

    // MARK: - Dependency manager
    
    var dependencyManager: VDependencyManager? {
        didSet {
            if dependencyManager !== oldValue {
                applyDependencyManagerStyles()
                avatarView.isVIPEnabled = dependencyManager?.isVIPEnabled
            }
        }
    }
    
    private func applyDependencyManagerStyles() {
        let appearanceKey = user?.accessLevel.isCreator == true ? VNewProfileViewController.creatorAppearanceKey : VNewProfileViewController.userAppearanceKey
        let appearanceDependencyManager = dependencyManager?.childDependency(forKey: appearanceKey)
        
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
    
    private dynamic func currentUserDidUpdate() {
        // Only update the header if we are displaying the current user.
        guard self.user?.id == VCurrentUser.user?.id else {
            return
        }

        user = VCurrentUser.user
    }
    
    private dynamic func currentUserDidChange() {
        user = VCurrentUser.user
    }
    
    private func populateUserContent() {
        let userIsCreator = user?.accessLevel.isCreator == true
        
        statsContainerView.isHidden = userIsCreator
        
        if user?.displayName?.isEmpty == false {
            displayNameLabel.text = user?.displayName
            usernameLabel.text = user?.username
        }
        else {
            displayNameLabel.text = user?.username
            usernameLabel.text = ""
        }
        
        locationLabel.text = user?.location
        taglineLabel.text = user?.tagline
        upvotesGivenValueLabel?.text = numberFormatter.string(for: user?.likesGiven ?? 0)
        upvotesReceivedValueLabel?.text = numberFormatter.string(for: user?.likesReceived ?? 0)
        
        let tier = user?.fanLoyalty?.tier
        let shouldDisplayTier = tier?.isEmpty == false
        tierValueLabel.text = tier
        tierTitleLabel.isHidden = !shouldDisplayTier
        tierValueLabel.isHidden = !shouldDisplayTier
        
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
        
        contentContainerView.isHidden = user == nil
        loadingContainerView.isHidden = user != nil
    }
    
    private let numberFormatter = VLargeNumberFormatter()
    
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
        
        // FUTURE: Unbang this.
        let widthConstraint = v_addWidthConstraint(width)!
        let height = systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        
        removeConstraint(widthConstraint)
        
        return CGSize(width: width, height: height)
    }
    
    func gridStreamShouldRefresh() {
        delegate?.shouldRefresh()
    }
}

private extension VDependencyManager {
    var accentColor: UIColor? {
        return color(forKey: VDependencyManagerAccentColorKey)
    }
    
    var loadingSpinnerColor: UIColor? {
        return color(forKey: VDependencyManagerMainTextColorKey)
    }
    
    var headerTextColor: UIColor? {
        return color(forKey: "color.text.header")
    }
    
    var statValueTextColor: UIColor? {
        return color(forKey: VDependencyManagerContentTextColorKey)
    }
    
    var statLabelTextColor: UIColor? {
        return color(forKey: VDependencyManagerSecondaryTextColorKey)
    }
    
    var infoTextColor: UIColor? {
        return color(forKey: "color.text.paragraph")
    }
    
    var headerFont: UIFont? {
        return font(forKey: VDependencyManagerHeaderFontKey)
    }
    
    var statValueFont: UIFont? {
        return font(forKey: VDependencyManagerHeading2FontKey)
    }
    
    var statLabelFont: UIFont? {
        return font(forKey: VDependencyManagerLabel2FontKey)
    }
    
    var infoFont: UIFont? {
        return font(forKey: VDependencyManagerParagraphFontKey)
    }
    
    var vipIcon: UIImage? {
        return image(forKey: "vipIcon")?.withRenderingMode(.alwaysTemplate)
    }
    
    var receivedUpvotesTitle: String? {
        return string(forKey: "upvoted.text")
    }
    
    var givenUpvotesTitle: String? {
        return string(forKey: "upvotes.text")
    }
    
    var tierTitle: String? {
        return string(forKey: "status.text")
    }
}
