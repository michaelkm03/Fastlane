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
}

/// A reusable view for displaying a user's avatar that handles decoration and fallback images.
///
/// For consistency in layout, it's recommended to allow the avatar view to size itself via its `intrinsicContentSize`
/// or to use that value when calculating layout manually.
///
class AvatarView: UIView {
    private struct Constants {
        static let shadowRadius = CGFloat(1.0)
        static let shadowOpacity = Float(0.2)
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
        clipsToBounds = false
        imageView.clipsToBounds = true
        
        shadowView.layer.shadowColor = Constants.shadowColor.CGColor
        shadowView.layer.shadowRadius = Constants.shadowRadius
        shadowView.layer.shadowOpacity = Constants.shadowOpacity
        shadowView.layer.shadowOffset = Constants.shadowOffset
        
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
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    // MARK: - Content
    
    var user: UserModel? {
        didSet {
            guard user?.id != oldValue?.id else {
                return
            }
            
            needsContentUpdate = true
            setNeedsLayout()
        }
    }
    
    private var needsContentUpdate = false
    
    private func updateContentIfNeeded() {
        guard needsContentUpdate else {
            return
        }
        
        needsContentUpdate = false
        
        imageView.backgroundColor = user?.color
        
        if let imageURL = user?.previewImageURL(ofMinimumSize: bounds.size) {
            imageView.image = nil
            initialsLabel.hidden = true
            
            imageView.sd_setImageWithURL(imageURL) { [weak self] _, error, _, _ in
                if error != nil {
                    self?.showInitials()
                }
            }
        }
        else {
            showInitials()
        }
    }
    
    private func showInitials() {
        initialsLabel.hidden = false
        // TODO: Update label.
    }
    
    // MARK: - Layout
    
    override func intrinsicContentSize() -> CGSize {
        return size.value
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shadowView.frame = bounds
        imageView.frame = bounds
        initialsLabel.frame = bounds
        imageView.layer.cornerRadius = bounds.size.v_roundCornerRadius
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
