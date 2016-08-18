//
//  AccessoryScreenContainer.swift
//  victorious
//
//  Created by Michael Sena on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// A protocol that can be conformed to, typically by a view controller, to handle automatic conversion of templatized
/// accessory screens to navigation bar buttons.
protocol AccessoryScreenContainer: class {
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
    
    /// Allows conformers to specify whether a particular screen should be shown.
    func shouldDisplay(screen: AccessoryScreen) -> Bool
    
    /// Called whenever an accessory screen's navigation button is pressed. Conformers must implement this to define
    /// how navigation to an accessory screen is performed.
    func navigate(to destination: UIViewController, from accessoryScreen: AccessoryScreen)
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
    
    func shouldDisplay(screen: AccessoryScreen) -> Bool {
        return true
    }
    
    // MARK: - Adding accessory screens
    
    /// Applies the templatized accessory screens from `dependencyManager` to the supplied `navigationItem`.
    ///
    /// This creates bar button items from `dependencyManager`'s accessory screens and assigns them to the left and
    /// right bar button items of `navigationItem`, supplementing them with the container's provided custom items.
    ///
    /// The templatized accessory screens are located via the container's `accessoryScreensKey`. If the key is nil, no
    /// bar button items will be assigned.
    ///
    /// This method can be called multiple times to update the bar buttons, which can be useful if, for example, your
    /// custom items change.
    ///
    func applyAccessoryScreens(to navigationItem: UINavigationItem, from dependencyManager: VDependencyManager) {
        guard let key = accessoryScreensKey, let unfilteredScreens = dependencyManager.accessoryScreens(for: key) else {
            return
        }
        
        let filteredScreens = unfilteredScreens.filter { shouldDisplay($0) }
        var leftScreens = [AccessoryScreen]()
        var rightScreens = [AccessoryScreen]()
        
        for screen in filteredScreens {
            switch screen.position {
                case .left: leftScreens.append(screen)
                case .right: rightScreens.append(screen)
            }
        }
        
        let leftItems = addCustomLeftItems(to: leftScreens.map { screen in
            AccessoryScreenBarButtonItem(accessoryScreen: screen, container: self)
        })
        
        let rightItems = addCustomRightItems(to: rightScreens.map { screen in
            AccessoryScreenBarButtonItem(accessoryScreen: screen, container: self)
        })
        
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.setLeftBarButtonItems(leftItems, animated: false)
        navigationItem.setRightBarButtonItems(rightItems, animated: false)
    }
}

private class AccessoryScreenBarButtonItem: UIBarButtonItem {
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    // MARK: - Views
    
    private let button = UIButton(type: .System)
    
    // MARK: - Navigating
    
    private let accessoryScreen: AccessoryScreen
    private weak var container: AccessoryScreenContainer?
    
    private dynamic func buttonWasPressed() {
        guard let destination = accessoryScreen.loadDestination() else {
            return
        }
        
        container?.navigate(to: destination, from: accessoryScreen)
    }
}
