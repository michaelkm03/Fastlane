//
//  BadgeButton.swift
//  victorious
//
//  Created by Jarod Long on 8/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// A button that can display a badge on its corner.
class BadgeButton: UIButton {
    
    // MARK: - Constants
    
    private struct Constants {
        static let badgePadding = CGFloat(1.0)
        static let badgeTextColor = UIColor.whiteColor()
        static let badgeBackgroundColor = UIColor(red: 0.95, green: 0.05, blue: 0.05, alpha: 1.0)
        static let badgeFont = UIFont.systemFontOfSize(13.0, weight: UIFontWeightRegular)
    }
    
    // MARK: - Accessing badge content
    
    /// The string of text to display in the button's badge.
    var badgeString: String? {
        didSet {
            badgeLabel.text = badgeString
            
            if badgeString?.isEmpty == false {
                addSubview(badgeLabel)
            }
            else {
                badgeLabel.removeFromSuperview()
            }
        }
    }
    
    /// Sets the badge string to a localized integer value, or nil if the number is less than 1.
    func setBadgeNumber(badgeNumber: Int) {
        badgeString = badgeNumber > 0 ? NSNumberFormatter.integerFormatter.stringFromNumber(badgeNumber) : nil
    }
    
    // MARK: - Subviews
    
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .Center
        label.textColor = Constants.badgeTextColor
        label.backgroundColor = Constants.badgeBackgroundColor
        label.font = Constants.badgeFont
        label.clipsToBounds = true
        label.userInteractionEnabled = false
        return label
    }()
    
    // MARK: - Layout
    
    /// The point on which the badge will be centered. Can be overridden to customize the badge position.
    var badgeAnchorPoint: CGPoint {
        let anchorFrame = imageView?.image == nil ? bounds : imageView?.frame ?? bounds
        
        return CGPoint(
            x: anchorFrame.maxX,
            y: anchorFrame.maxY
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let intrinsicBadgeSize = badgeLabel.intrinsicContentSize()
        let badgeSize = CGSize(width: max(intrinsicBadgeSize.width, intrinsicBadgeSize.height), height: intrinsicBadgeSize.height)
        
        badgeLabel.frame = badgeSize.centered(on: badgeAnchorPoint).insetBy(
            dx: -Constants.badgePadding,
            dy: -Constants.badgePadding
        )
        
        badgeLabel.layer.cornerRadius = badgeLabel.frame.size.v_roundCornerRadius
    }
}
