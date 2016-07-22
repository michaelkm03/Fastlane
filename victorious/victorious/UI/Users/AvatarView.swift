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
    
    // MARK: - Configuration
    
    var size = AvatarViewSize.small {
        didSet {
            if size != oldValue {
                applyInitialsStyle()
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
    
    // MARK: - Content
    
    var user: UserModel? {
        didSet {
            setNeedsContentUpdate()
            
            kvoController.unobserveAll()
            
            if let newUser = user as? AnyObject {
                let keyPaths = ["previewAssets", "name"]
                
                kvoController.observe(newUser, keyPaths: keyPaths, options: []) { [weak self] _, _, _ in
                    self?.setNeedsContentUpdate()
                }
            }
        }
    }
    
    private let kvoController = KVOController()
    
    // MARK: - Updating content
    
    private var needsContentUpdate = false
    
    func setNeedsContentUpdate() {
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
        
        if let imageURL = user?.previewImageURL(ofMinimumSize: bounds.size) {
            imageView.sd_setImageWithURL(imageURL) { [weak self] _, error, _, _ in
                if error != nil {
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
        guard let initials = user?.name?.initials() else {
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
        updateShadowPathIfNeeded()
        updateContentIfNeeded()
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
