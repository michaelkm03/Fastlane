//
//  SideNavProfileButton.swift
//  victorious
//
//  Created by Jarod Long on 8/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

/// The button that displays the user's profile image in the side nav scaffold and takes them to their profile.
///
/// It inherits from `BadgeButton` to support displaying badges relevant to the user's profile. 
///
class SideNavProfileButton: BadgeButton {
    
    // MARK: - Constants
    
    fileprivate struct Constants {
        static let badgeAngle = CGFloat(M_PI * 0.25)
        static let badgeCountType = BadgeCountType.unreadNotifications
    }
    
    // MARK: - Initializing
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        addSubview(avatarView)
        updateBadgeCount()
        
        BadgeCountManager.shared.whenBadgeCountChanges(for: Constants.badgeCountType) { [weak self] in
            self?.updateBadgeCount()
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    // MARK: - Accessing the user
    
    /// The user whose image is displayed in the button.
    var user: UserModel? {
        get {
            return avatarView.user
        }
        set {
            avatarView.user = newValue
        }
    }
    
    // MARK: - Views
    
    fileprivate let avatarView: AvatarView = {
        let view = AvatarView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    // MARK: - Managing badge count
    
    fileprivate func updateBadgeCount() {
        setBadgeNumber(BadgeCountManager.shared.badgeCount(for: Constants.badgeCountType) ?? 0)
    }
    
    // MARK: - Layout
    
    override var badgeAnchorPoint: CGPoint {
        return CGPoint(
            angle: Constants.badgeAngle,
            onEdgeOfCircleWithRadius: bounds.width / 2.0,
            origin: bounds.center
        )
    }

    override var intrinsicContentSize: CGSize {
        return avatarView.intrinsicContentSize
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return intrinsicContentSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarView.frame = bounds
    }
}
