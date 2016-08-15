//
//  SubscribeButton.swift
//  victorious
//
//  Created by Jarod Long on 8/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// A reusable button that can be used for navigating to the VIP subscription flow.
///
/// If the user is already a VIP subscriber, then this will show a non-interactive icon instead.
///
class SubscribeButton: UIView {
    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        userIsVIPButton = dependencyManager.userIsVIPButton
        
        super.init(frame: CGRect.zero)
        
        subscribeButton.translatesAutoresizingMaskIntoConstraints = false
        userIsVIPButton?.translatesAutoresizingMaskIntoConstraints = false
        
        subscribeButton.setTitle(NSLocalizedString("Upgrade", comment: ""), forState: .Normal)
        subscribeButton.sizeToFit()
        subscribeButton.addTarget(self, action: #selector(subscribeButtonWasPressed), forControlEvents: .TouchUpInside)
        updateVIPState()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userVIPStatusDidChange), name: VIPSubscriptionHelper.userVIPStatusChangedNotificationKey, object: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    // MARK: - Dependency manager
    
    private let dependencyManager: VDependencyManager
    
    // MARK: - Subviews
    
    private let subscribeButton = BackgroundButton(type: .System)
    private let userIsVIPButton: UIButton?
    
    private var visibleButton: UIButton? {
        return userIsVIP == true ? userIsVIPButton : subscribeButton
    }
    
    private var hiddenButton: UIButton? {
        return userIsVIP == true ? subscribeButton : userIsVIPButton
    }
    
    // MARK: - Actions
    
    private dynamic func subscribeButtonWasPressed() {
        guard let scaffold = VRootViewController.sharedRootViewController()?.scaffold else {
            return
        }
        
        Router(originViewController: scaffold, dependencyManager: dependencyManager).navigate(to: .vipSubscription)
    }
    
    // MARK: - Responding to VIP changes
    
    private var userIsVIP: Bool? {
        didSet {
            guard userIsVIP != oldValue else {
                return
            }
            
            if let visibleButton = visibleButton {
                addSubview(visibleButton)
                visibleButton.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
                visibleButton.trailingAnchor.constraintEqualToAnchor(trailingAnchor).active = true
            }
            
            hiddenButton?.removeFromSuperview()
            invalidateIntrinsicContentSize()
        }
    }
    
    private func updateVIPState() {
        userIsVIP = VCurrentUser.user()?.hasValidVIPSubscription == true
    }
    
    private dynamic func userVIPStatusDidChange(notification: NSNotification) {
        updateVIPState()
    }
    
    // MARK: - Layout
    
    override func intrinsicContentSize() -> CGSize {
        return (visibleButton ?? subscribeButton).intrinsicContentSize()
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        return intrinsicContentSize()
    }
}

private extension VDependencyManager {
    var userIsVIPButton: UIButton? {
        return buttonForKey("button.vip")
    }
}
