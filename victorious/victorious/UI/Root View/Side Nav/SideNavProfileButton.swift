//
//  SideNavProfileButton.swift
//  victorious
//
//  Created by Jarod Long on 8/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// The button that displays the user's profile image in the side nav scaffold and takes them to their profile.
///
/// It inherits from `BadgeButton` to support displaying badges relevant to the user's profile. 
///
class SideNavProfileButton: BadgeButton {
    
    private struct Constants {
        static let badgeAngle = CGFloat(M_PI * 0.25)
    }
    
    // MARK: - Accessing the user
    
    /// The user whose image is displayed in the button.
    var user: UserModel? {
        get {
            return avatarView.user
        }
        set {
            avatarView.user = newValue
            addSubview(avatarView)
            badgeString = "12"
        }
    }
    
    // MARK: - Views
    
    private let avatarView: AvatarView = {
        let view = AvatarView()
        view.userInteractionEnabled = false
        return view
    }()
    
    // MARK: - Layout
    
    override var badgeAnchorPoint: CGPoint {
        return CGPoint(
            angle: Constants.badgeAngle,
            onEdgeOfCircleWithRadius: bounds.width / 2.0,
            origin: bounds.center
        )
    }
    
    override func intrinsicContentSize() -> CGSize {
        return avatarView.intrinsicContentSize()
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        return intrinsicContentSize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarView.frame = bounds
    }
}
