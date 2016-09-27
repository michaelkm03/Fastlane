//
//  AccessoryScreen.swift
//  victorious
//
//  Created by Jarod Long on 8/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// A struct that represents an accessory screen that comes from a template.
struct AccessoryScreen {
    
    // MARK: - Initializing
    
    init?(dependencyManager: VDependencyManager) {
        guard let id = dependencyManager.stringForKey("identifier") else {
            Log.warning("Tried to initialize an accessory screen without an identifier.")
            return nil
        }
        
        self.dependencyManager = dependencyManager
        self.id = id
        title = dependencyManager.stringForKey("title")
        icon = dependencyManager.imageForKey("icon")
        position = AccessoryScreenPosition(string: dependencyManager.stringForKey("position") ?? "") ?? .right
    }
    
    // MARK: - Dependency manager
    
    fileprivate let dependencyManager: VDependencyManager
    
    // MARK: - Accessing values
    
    /// A string that uniquely identifies a particular accessory screen used in the app.
    var id: String
    
    /// The title of the accessory screen.
    var title: String?
    
    /// An icon that can be used to display a button that navigates to this accessory screen.
    var icon: UIImage?
    
    /// The position of the accessory screen's button when displayed in a navigation bar.
    var position: AccessoryScreenPosition
    
    // MARK: - Loading the destination
    
    /// Loads the accessory screen's destination view controller and returns it if it exists.
    func loadDestination() -> UIViewController? {
        return dependencyManager.viewControllerForKey("destination")
    }
}

/// An enum for the position that an accessory screen's button can be located at.
enum AccessoryScreenPosition {
    case left, right
    
    init?(string: String) {
        switch string {
            case "left": self = .left
            case "right": self = .right
            default: return nil
        }
    }
}

extension VDependencyManager {
    /// Returns all of the accessory screens contained in the dependency manager at the given `key`, or nil if no
    /// accessory screens exist.
    func accessoryScreens(for key: String) -> [AccessoryScreen]? {
        guard let accessoryScreenDependencyManagers = childDependencies(for: key) else {
            Log.warning("Tried to get accessory screens from dependency manager for key '\(key)', but a value for that key was not found.")
            return nil
        }
        
        return accessoryScreenDependencyManagers.flatMap { AccessoryScreen(dependencyManager: $0) }
    }
}
