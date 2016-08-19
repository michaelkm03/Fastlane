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
    
    // MARK: - Subviews
    
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .Center
        label.textColor = .whiteColor()
        label.backgroundColor = .redColor()
        label.clipsToBounds = true
        return label
    }()
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let intrinsicBadgeSize = badgeLabel.intrinsicContentSize()
        let badgeLength = max(intrinsicBadgeSize.width, intrinsicBadgeSize.height)
        
        badgeLabel.frame = CGSize(width: badgeLength, height: badgeLength).centered(on: CGPoint(
            x: bounds.maxX,
            y: bounds.maxY
        ))
        
        badgeLabel.layer.cornerRadius = badgeLabel.frame.size.v_roundCornerRadius
    }
}
