//
//  AccessoryScreenBarButtonItem.swift
//  victorious
//
//  Created by Jarod Long on 8/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class AccessoryScreenBarButtonItem: UIBarButtonItem {
    
    // MARK: - Constants
    
    fileprivate struct Constants {
        static let extraWidth = CGFloat(16.0)
    }
    
    // MARK: - Initializing
    
    init(accessoryScreen: AccessoryScreen, container: AccessoryScreenContainer) {
        self.accessoryScreen = accessoryScreen
        self.container = container
        
        super.init()
        
        button.setImage(accessoryScreen.icon, for: UIControlState())
        button.addTarget(self, action: #selector(buttonWasPressed), for: .touchUpInside)
        
        var buttonSize = button.intrinsicContentSize
        buttonSize.width += Constants.extraWidth
        button.frame.size = buttonSize
        customView = button
        
        if let badgeCountType = container.badgeCountType(for: accessoryScreen) {
            updateBadgeCount()
            
            BadgeCountManager.shared.whenBadgeCountChanges(for: badgeCountType) { [weak self] in
                self?.updateBadgeCount()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    // MARK: - Views
    
    fileprivate let button = BadgeButton(type: .system)
    
    // MARK: - Accessing the accessory screen
    
    let accessoryScreen: AccessoryScreen
    
    // MARK: - Managing badge count
    
    fileprivate func updateBadgeCount() {
        guard let badgeCountType = container?.badgeCountType(for: accessoryScreen) else {
            return
        }
        
        button.setBadgeNumber(BadgeCountManager.shared.badgeCount(for: badgeCountType) ?? 0)
    }
    
    // MARK: - Navigating
    
    fileprivate weak var container: AccessoryScreenContainer?
    
    fileprivate dynamic func buttonWasPressed() {
        guard let destination = accessoryScreen.loadDestination() else {
            return
        }
        
        container?.navigate(to: destination, from: accessoryScreen)
    }
}
