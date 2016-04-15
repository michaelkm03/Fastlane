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
    }
    
    // MARK: - Models
    
    var user: VUser? {
        didSet {
            populateUserContent()
        }
    }
    
    // MARK: - Views
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var vipIconImageView: UIImageView!
    @IBOutlet var upvotesValueLabel: UILabel!
    @IBOutlet var upvotesTitleLabel: UILabel!
    @IBOutlet var upvotedValueLabel: UILabel!
    @IBOutlet var upvotedTitleLabel: UILabel!
    @IBOutlet var rankValueLabel: UILabel!
    @IBOutlet var rankTitleLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var taglineLabel: UILabel!
    @IBOutlet var profilePictureView: UIImageView!
    @IBOutlet var profilePictureShadowView: UIView!
    
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
    }
    
    // MARK: - Populating content
    
    private func populateUserContent() {
        nameLabel.text = user?.name
        locationLabel.text = user?.location
        taglineLabel.text = user?.tagline
        vipIconImageView.hidden = user?.isVIPSubscriber?.boolValue != true
        
        let placeholderImage = UIImage(named: "profile_full")
        
        if let picturePath = user?.pictureUrl, pictureURL = NSURL(string: picturePath) {
            profilePictureView.sd_setImageWithURL(pictureURL, placeholderImage: placeholderImage)
        } else {
            profilePictureView.image = placeholderImage
        }
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
