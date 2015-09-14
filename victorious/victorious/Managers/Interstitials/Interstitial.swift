//
//  Interstitial.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// An enum describing each type of supported interstitials
enum InterstitialType : String {
    case LevelUp = "level"
}

/// An Interstial object represents a screen that can be displayed over the app
/// at any time during the app's flow.
class Interstitial: InterstitialConfiguration, Hashable {
    
    let remoteID: Int
    
    var dependencyManager: VDependencyManager?
        
    init(id: Int) {
        remoteID = id
    }
    
    /// Returns a properly configured Interstitial subclass
    ///
    /// :param: info A dictionary representing the interstitial
    class func configuredInterstitial(info: [String : AnyObject]) -> Interstitial? {
        var interstitial: Interstitial?
        if let type = info["type"] as? String, idString = info["id"] as? String, id = idString.toInt() {
            if type == InterstitialType.LevelUp.rawValue {
                interstitial = LevelUpInterstitial(id: id)
            }
        }
        interstitial?.configureWithInfo(info)
        return interstitial
    }
    
    /// MARK: InterstitialConfiguration
    
    func configureWithInfo(info: [String : AnyObject]) {
        // Subclasses should implement to set correct info
    }
    
    func viewControllerToPresent() -> InterstitialViewController? {
        // Subclasses should implement to return appropriate view controller for Interstitial
        return nil
    }
    
    /// MARK: Hashable
    
    var hashValue: Int {
        return remoteID
    }
}

// Equatable conformance
func ==(lhs: Interstitial, rhs: Interstitial) -> Bool {
    return lhs.remoteID == rhs.remoteID
}
