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
        
        guard dependencyManager.subscriptionEnabled else {
            hidden = true
            return
        }
        
        subscribeButton.translatesAutoresizingMaskIntoConstraints = false
        userIsVIPButton?.translatesAutoresizingMaskIntoConstraints = false
        
        subscribeButton.setTitle(NSLocalizedString("Upgrade", comment: ""), forState: .Normal)
        subscribeButton.sizeToFit()
        subscribeButton.addTarget(self, action: #selector(subscribeButtonWasPressed), forControlEvents: .TouchUpInside)
        updateVIPState()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userStatusDidChange), name: VCurrentUser.userDidUpdateNotificationKey, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userStatusDidChange), name: kLoggedInChangedNotification, object: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    // MARK: - Dependency manager
    
    fileprivate let dependencyManager: VDependencyManager
    
    // MARK: - Subviews
    
    fileprivate let subscribeButton = BackgroundButton(type: .system)
    fileprivate let userIsVIPButton: UIButton?
    
    fileprivate var visibleButton: UIButton? {
        return userIsVIP == true ? userIsVIPButton : subscribeButton
    }
    
    fileprivate var hiddenButton: UIButton? {
        return userIsVIP == true ? subscribeButton : userIsVIPButton
    }
    
    // MARK: - Actions
    
    fileprivate dynamic func subscribeButtonWasPressed() {
        guard let scaffold = VRootViewController.sharedRootViewController()?.scaffold else {
            return
        }
        
        Router(originViewController: scaffold, dependencyManager: dependencyManager).navigate(to: .vipSubscription, from: nil)
    }
    
    // MARK: - Responding to VIP changes
    
    fileprivate var userIsVIP: Bool? {
        didSet {
            guard userIsVIP != oldValue else {
                return
            }
            
            if let visibleButton = visibleButton {
                addSubview(visibleButton)
                visibleButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
                visibleButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            }
            
            hiddenButton?.removeFromSuperview()
            invalidateIntrinsicContentSize()
        }
    }
    
    fileprivate func updateVIPState() {
        userIsVIP = VCurrentUser.user?.hasValidVIPSubscription == true
    }
    
    fileprivate dynamic func userStatusDidChange(_ notification: Notification) {
        updateVIPState()
    }
    
    // MARK: - Layout
    
    override var intrinsicContentSize : CGSize {
        return (visibleButton ?? subscribeButton).intrinsicContentSize
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return intrinsicContentSize
    }
}

private extension VDependencyManager {
    var userIsVIPButton: UIButton? {
        return buttonForKey("button.vip")
    }
    
    var subscriptionEnabled: Bool {
        return childDependencyForKey("subscription")?.numberForKey("enabled")?.boolValue == true
    }
}
