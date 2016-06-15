//
//  AccessoryScreensKeyProvider.swift
//  victorious
//
//  Created by Michael Sena on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Objects in the responder chain that conform to this protocol have an opportunity to provide a new key 
/// for the accessory screens infrastructure to read from in the dependencyManager.
@objc protocol AccessoryScreensKeyProvider {
   
    /// Implment this to read from a custom accessory screens key. Such as when a screen component's screens are
    /// based on some state like representing the current user or another user.
    ///
    /// - Returns: An appropriate key to use for finding accessory screens.
    ///
    func accessoryScreensKey() -> String?
    
}