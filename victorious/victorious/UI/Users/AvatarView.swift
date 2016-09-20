//
//  AvatarView.swift
//  victorious
//
//  Created by Jarod Long on 7/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// A preset configurable size for an `AvatarView`.
/// Uses a smaller size for iPhone 1-5s, and SE sized devices
enum AvatarViewSize {
    case small, large
    
    var value: CGSize {
        switch self {
            case .small: return CGSize(width: 30.0, height: 30.0)
            case .large:
                switch UIScreen.mainScreen().bounds.width {
                    case 320.0:
                        return CGSize(width: 75.0, height: 75.0)
                    default:
                        return CGSize(width: 90.0, height: 90.0)
                }
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

    var shouldShowVIPBadge: Bool {
        switch self {
            case .small: return false
            case .large: return true
        }
    }

    var shouldShowVIPBorder: Bool {
        switch self {
            case .small: return false
            case .large: return true
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

        static let vipColor = UIColor(red: 0.03137, green: 0.6980, blue: 0.1569, alpha: 1.0)
        static let vipBadgeViewAngle = CGFloat(M_PI * -0.75)
        static let vipBadgeViewDiameter = CGFloat(32.0)
        static let vipBadgeViewLabelFont = UIFont.systemFontOfSize(CGFloat(14), weight: UIFontWeightSemibold)
        static let vipBorderWidth = CGFloat(2.0)
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
        
        // This sets all of the subview's initial frames immediately without animation so that they don't animate from
        // initial frames of zero, which can create awkward transitions.
        UIView.performWithoutAnimation {
            self.layoutIfNeeded()
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(currentUserDidChange), name: VCurrentUser.userDidUpdateNotificationKey, object: nil)
    }

    // MARK: - Views
    
    private let shadowView = UIView()
    private let imageView = UIImageView()
    private let initialsLabel = UILabel()
    private var verifiedBadgeView: UIImageView?
    private var vipBadgeView: UIView?
    private var vipBorderView: UIView?
    
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

    private func setOrCreateVIPBadgeView() {
        if self.vipBadgeView != nil {
            return
        }

        let vipBadgeView = UIView()
        vipBadgeView.backgroundColor = Constants.vipColor
        self.vipBadgeView = vipBadgeView

        addSubview(vipBadgeView)

        let pointOnCircle = CGPoint(
            angle: Constants.vipBadgeViewAngle,
            onEdgeOfCircleWithRadius: bounds.width / 2.0,
            origin: bounds.center
        )

        vipBadgeView.frame = CGRect(
            center: pointOnCircle,
            size: CGSize(width: Constants.vipBadgeViewDiameter, height: Constants.vipBadgeViewDiameter)
        )

        vipBadgeView.layer.cornerRadius = vipBadgeView.frame.size.width / 2
        vipBadgeView.clipsToBounds = true

        let vipLabel = UILabel()
        vipLabel.font = Constants.vipBadgeViewLabelFont
        vipLabel.textColor = UIColor.whiteColor()
        vipLabel.text = "VIP"
        vipLabel.sizeToFit()
        let centeredFrame = CGRect(
            x: (vipBadgeView.frame.size.width / 2) - (vipLabel.frame.size.width / 2) ,
            y: (vipBadgeView.frame.size.height / 2) - (vipLabel.frame.size.height / 2) ,
            width: vipLabel.frame.size.width,
            height: vipLabel.frame.size.height
        )

        vipLabel.frame = centeredFrame
        vipBadgeView.addSubview(vipLabel)
    }

    private func setOrCreateVIPBorderView() {
        if self.vipBorderView != nil {
            return
        }

        let vipBorderView = UIView()
        vipBorderView.backgroundColor = Constants.vipColor

        addSubview(vipBorderView)
        sendSubviewToBack(vipBorderView)
        updateVIPBorderView()

        let vipBorderSize = CGSize(
            width: bounds.width + Constants.vipBorderWidth * 2,
            height: bounds.height + Constants.vipBorderWidth * 2
        )

        vipBorderView.frame = CGRect(center: bounds.center, size: vipBorderSize)
        vipBorderView.layer.cornerRadius = vipBorderView.frame.size.width / 2

        self.vipBorderView = vipBorderView
    }

    // MARK: - Configuration
    
    var size = AvatarViewSize.small {
        didSet {
            if size != oldValue {
                applyInitialsStyle()
                updateVerifiedBadge()
                updateVIPBadge()
                updateVIPBorderView()
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

    private func updateVIPBadge() {
        let shouldShowVIPBadge = user?.hasValidVIPSubscription == true && size.shouldShowVIPBorder
        vipBadgeView?.hidden = !shouldShowVIPBadge
    }

    private func updateVIPBorderView() {
        let shouldShowVIPBorder = user?.hasValidVIPSubscription == true && size.shouldShowVIPBorder
        vipBorderView?.hidden = !shouldShowVIPBorder
    }
    
    // MARK: - Content
    
    var user: UserModel? {
        didSet {
            guard user?.id != oldValue?.id else {
                return
            }
            
            setNeedsContentUpdate()
            // Force content update here because when we finish editing profile, the main feed chat bubble's avatar doesn't get it layout pass.
            updateContentIfNeeded()
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
            imageView.getImageAsset(imageAsset) { [weak self] result in
                switch result {
                    case .success(let image):
                        guard
                            let strongSelf = self
                            where strongSelf.user?.previewImage(ofMinimumSize: strongSelf.bounds.size)?.url == imageAsset.url
                        else {
                            return
                        }
                        
                        self?.imageView.image = image
                        self?.initialsLabel.hidden = true
                    
                    case .failure(_):
                        self?.showInitials()
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
    
    private dynamic func currentUserDidChange() {
        if user?.id == VCurrentUser.user?.id {
            // We may be updating the same user with more information here.
            // So we nil out the user property first before we set it.
            // Otherwise the user update may return early because we are setting the user with same userID
            user = nil
            user = VCurrentUser.user
        }
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
        layoutVIPBadge()
        layoutVIPBorderView()
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
        verifiedBadgeView.hidden = user?.avatarBadgeType != .verified
    }

    private func layoutVIPBadge() {
        guard size.shouldShowVIPBadge else {
            return
        }

        setOrCreateVIPBadgeView()
        updateVIPBadge()
    }

    private func layoutVIPBorderView() {
        guard size.shouldShowVIPBorder else {
            return
        }

        setOrCreateVIPBorderView()
        updateVIPBorderView()
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
