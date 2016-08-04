//
//  AvatarView.swift
//  victorious
//
//  Created by Jarod Long on 7/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// A preset configurable size for an `AvatarView`.
enum AvatarViewSize {
    case small, large
    
    var value: CGSize {
        switch self {
            case .small: return CGSize(width: 30.0, height: 30.0)
            case .large: return CGSize(width: 90.0, height: 90.0)
        }
    }
    
    var initialsFont: UIFont {
        switch self {
            case .small: return AvatarView.Constants.smallInitialsFont
            case .large: return AvatarView.Constants.largeInitialsFont
        }
    }
    
    var verifiedBadgeImage: UIImage? {
        switch self {
            case .small: return UIImage(named: "verified_badge_small")
            case .large: return UIImage(named: "verified_badge_large")
        }
    }
}

/// A reusable view for displaying a user's avatar that handles decoration and fallback images.
///
/// For consistency in layout, it's recommended to allow the avatar view to size itself via its `intrinsicContentSize`
/// or to use that value when calculating layout manually.
///
class AvatarView: UIView {
    private struct Constants {
        static let smallInitialsFont = UIFont.systemFontOfSize(14.0, weight: UIFontWeightMedium)
        static let largeInitialsFont = UIFont.systemFontOfSize(42.0, weight: UIFontWeightSemibold)
        static let initialsColor = UIColor(white: 0.0, alpha: 0.7)
        static let initialsMinScaleFactor = CGFloat(0.5)
        
        static let borderColor = UIColor(white: 0.0, alpha: 0.12)
        static let borderWidth = CGFloat(0.5)
        
        static let shadowRadius = CGFloat(0.5)
        static let shadowOpacity = Float(0.1)
        static let shadowColor = UIColor.blackColor()
        static let shadowOffset = CGSize(width: 0.0, height: 1.0)
        
        static let verifiedBadgeAngle = CGFloat(M_PI * 0.25)
        static let observationKeys = ["displayName", "previewAssets"]
    }
    
    // MARK: - Initializing
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = nil
        clipsToBounds = false
        imageView.clipsToBounds = true
        
        shadowView.layer.borderColor = Constants.borderColor.CGColor
        shadowView.layer.borderWidth = Constants.borderWidth
        shadowView.layer.shadowColor = Constants.shadowColor.CGColor
        shadowView.layer.shadowRadius = Constants.shadowRadius
        shadowView.layer.shadowOpacity = Constants.shadowOpacity
        shadowView.layer.shadowOffset = Constants.shadowOffset
        
        applyInitialsStyle()
        
        addSubview(shadowView)
        addSubview(imageView)
        addSubview(initialsLabel)
    }
    
    // MARK: - Views
    
    private let shadowView = UIView()
    private let imageView = UIImageView()
    private let initialsLabel = UILabel()
    private var verifiedBadgeView: UIImageView?
    
    private func getOrCreateVerifiedBadgeView() -> UIImageView {
        if let verifiedBadgeView = self.verifiedBadgeView {
            return verifiedBadgeView
        }
        
        let verifiedBadgeView = UIImageView()
        self.verifiedBadgeView = verifiedBadgeView
        addSubview(verifiedBadgeView)
        updateVerifiedBadge()
        return verifiedBadgeView
    }
    
    // MARK: - Configuration
    
    var size = AvatarViewSize.small {
        didSet {
            if size != oldValue {
                applyInitialsStyle()
                updateVerifiedBadge()
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    private func applyInitialsStyle() {
        initialsLabel.textAlignment = .Center
        initialsLabel.adjustsFontSizeToFitWidth = true
        initialsLabel.minimumScaleFactor = Constants.initialsMinScaleFactor
        initialsLabel.font = size.initialsFont
        initialsLabel.textColor = Constants.initialsColor
    }
    
    private func updateVerifiedBadge() {
        verifiedBadgeView?.image = size.verifiedBadgeImage
    }
    
    // MARK: - Content
    
    var user: UserModel? {
        didSet {
            var persistentUser: VUser?
            if let user = user as? VUser {
                persistentUser = user
            }
            
            guard user?.id != oldValue?.id || persistentUser == nil else {
                // Only prevent updating for a persistent user since we can KVO values related to that object
                return
            }
            
            setNeedsContentUpdate()
            
            setupKVO()
        }
    }
    
    // MARK: - KVO 
    
    /// This class handles KVO using the Foundation APIs since FBKVOController has a weird bug with multiple instances
    /// of the same class observing the same object. 
    /// Also, the user object can be a userModel, which may or may not be persistent. Only the persistent VUser can 
    /// be KVO'd, hence we must check for this in the setup function.
    private func setupKVO() {
        guard let user = self.user as? VUser else {
            return
        }
        
        KVOController.unobserveAll()
        KVOController.observe(user, keyPaths: Constants.observationKeys, options: [.Initial, .New]) { [weak self] _ in
            self?.setNeedsContentUpdate()
        }
    }
    
    // MARK: - Updating content
    
    private var needsContentUpdate = false
    
    private func setNeedsContentUpdate() {
        needsContentUpdate = true
        setNeedsLayout()
    }
    
    private func updateContentIfNeeded() {
        guard needsContentUpdate else {
            return
        }
        
        needsContentUpdate = false
        
        imageView.image = nil
        imageView.backgroundColor = user?.color
        
        if let imageAsset = user?.previewImage(ofMinimumSize: bounds.size) {
            imageView.setImageAsset(imageAsset) { [weak self] image, _ in
                if image == nil {
                    self?.showInitials()
                }
                else {
                    self?.initialsLabel.hidden = true
                }
            }
        }
        else {
            showInitials()
        }
    }
    
    private func showInitials() {
        guard let initials = user?.displayName?.initials() else {
            initialsLabel.hidden = true
            return
        }
        
        initialsLabel.hidden = false
        initialsLabel.text = initials
    }
    
    // MARK: - Layout
    
    override func intrinsicContentSize() -> CGSize {
        return size.value
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        return intrinsicContentSize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shadowView.frame = bounds.insetBy(dx: -Constants.borderWidth, dy: -Constants.borderWidth)
        imageView.frame = bounds
        initialsLabel.frame = bounds
        imageView.layer.cornerRadius = imageView.frame.size.v_roundCornerRadius
        shadowView.layer.cornerRadius = shadowView.frame.size.v_roundCornerRadius
        layoutVerifiedBadge()
        updateShadowPathIfNeeded()
        updateContentIfNeeded()
    }
    
    private func layoutVerifiedBadge() {
        guard user?.avatarBadgeType == .verified else {
            self.verifiedBadgeView?.hidden = true
            return
        }
        
        let verifiedBadgeView = getOrCreateVerifiedBadgeView()
        let size = verifiedBadgeView.intrinsicContentSize()
        
        let pointOnCircle = CGPoint(
            angle: Constants.verifiedBadgeAngle,
            onEdgeOfCircleWithRadius: bounds.width / 2.0,
            origin: bounds.center
        )
        
        verifiedBadgeView.frame = CGRect(center: pointOnCircle, size: size)
        verifiedBadgeView.hidden = false
    }
    
    // MARK: - Shadow
    
    private var shadowBounds: CGRect?
    
    private func updateShadowPathIfNeeded() {
        let newShadowBounds = shadowView.bounds
        
        if newShadowBounds != shadowBounds {
            shadowBounds = newShadowBounds
            shadowView.layer.shadowPath = UIBezierPath(ovalInRect: newShadowBounds).CGPath
        }
    }
}
