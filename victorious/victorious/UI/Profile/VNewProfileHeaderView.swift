//
//  VNewProfileHeaderView.swift
//  victorious
//
//  Created by Jarod Long on 4/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// The collection header view used for `VNewProfileViewController`.
class VNewProfileHeaderView: UICollectionReusableView {
    // MARK: - Constants
    
    private static let shadowRadius: CGFloat = 2.0
    private static let shadowOpacity: Float = 0.5
    
    // MARK: - Initializing
    
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
            populateUserContent()
        }
    }
    
    // MARK: - Views
    
    @IBOutlet private var contentContainerView: UIView!
    @IBOutlet private var loadingContainerView: UIView!
    @IBOutlet private var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var vipIconImageView: UIImageView!
    @IBOutlet private var upvotesValueLabel: UILabel!
    @IBOutlet private var upvotesTitleLabel: UILabel!
    @IBOutlet private var upvotedValueLabel: UILabel!
    @IBOutlet private var upvotedTitleLabel: UILabel!
    @IBOutlet private var rankValueLabel: UILabel!
    @IBOutlet private var rankTitleLabel: UILabel!
    @IBOutlet private var locationLabel: UILabel!
    @IBOutlet private var taglineLabel: UILabel!
    @IBOutlet private var profilePictureView: UIImageView!
    @IBOutlet private var profilePictureShadowView: UIView!
    
    // MARK: - Dependency manager
    
    var dependencyManager: VDependencyManager? {
        didSet {
            if dependencyManager !== oldValue {
                applyDependencyManagerStyles()
            }
        }
    }
    
    private func applyDependencyManagerStyles() {
        tintColor = dependencyManager?.accentColor

        nameLabel.textColor = dependencyManager?.headerTextColor
        upvotesValueLabel.textColor = dependencyManager?.statValueTextColor
        upvotesTitleLabel.textColor = dependencyManager?.statLabelTextColor
        upvotedValueLabel.textColor = dependencyManager?.statValueTextColor
        upvotedTitleLabel.textColor = dependencyManager?.statLabelTextColor
        rankValueLabel.textColor = dependencyManager?.statValueTextColor
        rankTitleLabel.textColor = dependencyManager?.statLabelTextColor
        locationLabel.textColor = dependencyManager?.subcontentTextColor
        taglineLabel.textColor = dependencyManager?.subcontentTextColor
        
        nameLabel.font = dependencyManager?.headerFont
        upvotesValueLabel.font = dependencyManager?.statValueFont
        upvotesTitleLabel.font = dependencyManager?.statLabelFont
        upvotedValueLabel.font = dependencyManager?.statValueFont
        upvotedTitleLabel.font = dependencyManager?.statLabelFont
        rankValueLabel.font = dependencyManager?.statValueFont
        rankTitleLabel.font = dependencyManager?.statLabelFont
        locationLabel.font = dependencyManager?.subcontentFont
        taglineLabel.font = dependencyManager?.subcontentFont
        
        vipIconImageView.image = dependencyManager?.vipIcon
        
        loadingSpinner.color = dependencyManager?.loadingSpinnerColor
    }
    
    // MARK: - Populating content
    
    private func populateUserContent() {
        nameLabel.text = user?.name
        locationLabel.text = user?.location
        taglineLabel.text = user?.tagline
        vipIconImageView.hidden = user?.isVIPSubscriber?.boolValue != true
        
        let placeholderImage = UIImage(named: "profile_full")
        
        if let pictureURL = user?.pictureURL(ofMinimumSize: profilePictureView.frame.size) {
            profilePictureView.sd_setImageWithURL(pictureURL, placeholderImage: placeholderImage)
        } else {
            profilePictureView.image = placeholderImage
        }
        
        contentContainerView.hidden = user == nil
        loadingContainerView.hidden = user != nil
    }
    
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
    
    var subcontentTextColor: UIColor? {
        return colorForKey("color.text.subcontent")
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
    
    var subcontentFont: UIFont? {
        return fontForKey(VDependencyManagerParagraphFontKey)
    }
    
    var vipIcon: UIImage? {
        return imageForKey("vipIcon")?.imageWithRenderingMode(.AlwaysTemplate)
    }
}