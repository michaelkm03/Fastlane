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
        backgroundColor = dependencyManager?.colorForKey(VDependencyManagerBackgroundColorKey)
        
        let mainTextColor = dependencyManager?.colorForKey(VDependencyManagerContentTextColorKey)
        let secondaryTextColor = dependencyManager?.colorForKey(VDependencyManagerSecondaryTextColorKey)
        
        nameLabel.textColor = mainTextColor
        upvotesValueLabel.textColor = mainTextColor
        upvotesTitleLabel.textColor = secondaryTextColor
        upvotedValueLabel.textColor = mainTextColor
        upvotedTitleLabel.textColor = secondaryTextColor
        rankValueLabel.textColor = mainTextColor
        rankTitleLabel.textColor = secondaryTextColor
        locationLabel.textColor = mainTextColor
        taglineLabel.textColor = mainTextColor
    }
    
    // MARK: - Populating content
    
    private func populateUserContent() {
        nameLabel.text = user?.name
        locationLabel.text = user?.location
        taglineLabel.text = user?.tagline
        
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
