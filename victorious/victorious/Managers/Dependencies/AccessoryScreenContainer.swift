//
//  AccessoryScreenContainer.swift
//  victorious
//
//  Created by Michael Sena on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Objects in the responder chain that conform to this protocol are given opportunities to customize their role in the
/// dependency manager accessory screen system.
protocol AccessoryScreenContainer {
    /// Implement this to read from a custom accessory screens key. Such as when a screen component's screens are
    /// based on some state like representing the current user or another user. This key is optional because some
    /// screens may rely on the network to determine *which* key they should return here.
    ///
    /// - Returns: An appropriate key to use for finding accessory screens.
    ///
    var accessoryScreensKey: String? { get }
    
    /// Allows conformers to augment the left bar button items created from the template with their own custom items.
    func addCustomLeftItems(to items: [UIBarButtonItem]) -> [UIBarButtonItem]
    
    /// Allows conformers to augment the right bar button items created from the template with their own custom items.
    func addCustomRightItems(to items: [UIBarButtonItem]) -> [UIBarButtonItem]
}

extension AccessoryScreenContainer {
    // MARK: - Default implementations
    
    var accessoryScreensKey: String? {
        return "accessoryScreens"
    }
    
    func addCustomLeftItems(to items: [UIBarButtonItem]) -> [UIBarButtonItem] {
        return items
    }
    
    func addCustomRightItems(to items: [UIBarButtonItem]) -> [UIBarButtonItem] {
        return items
    }
    
    // MARK: - Adding accessory screens
    
    func addAccessoryScreens(to navigationItem: UINavigationItem, from dependencyManager: VDependencyManager) {
        // TODO: Implement me!
    }
}
