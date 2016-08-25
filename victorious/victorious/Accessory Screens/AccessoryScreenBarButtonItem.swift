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
    
    private struct Constants {
        static let extraWidth = CGFloat(16.0)
    }
    
    // MARK: - Initializing
    
    init(accessoryScreen: AccessoryScreen, container: AccessoryScreenContainer) {
        self.accessoryScreen = accessoryScreen
        self.container = container
        
        super.init()
        
        button.setImage(accessoryScreen.icon, forState: .Normal)
        button.addTarget(self, action: #selector(buttonWasPressed), forControlEvents: .TouchUpInside)
        
        var buttonSize = button.intrinsicContentSize()
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
    
    private let button = BadgeButton(type: .System)
    
    // MARK: - Accessing the accessory screen
    
    let accessoryScreen: AccessoryScreen
    
    // MARK: - Managing badge count
    
    private func updateBadgeCount() {
        guard let badgeCountType = container?.badgeCountType(for: accessoryScreen) else {
            return
        }
        
        button.setBadgeNumber(BadgeCountManager.shared.badgeCount(for: badgeCountType) ?? 0)
    }
    
    // MARK: - Navigating
    
    private weak var container: AccessoryScreenContainer?
    
    private dynamic func buttonWasPressed() {
        guard let destination = accessoryScreen.loadDestination() else {
            return
        }
        
        container?.navigate(to: destination, from: accessoryScreen)
    }
}
