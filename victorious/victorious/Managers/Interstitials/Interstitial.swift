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
    /// WARNING: change this to "levelUp" when backend implements level up interstitial
    case LevelUp = ""
}

/// An Interstial object represents a screen that can be displayed over the app
/// at any time during the app's flow.
class Interstitial: InterstitialConfiguration, Hashable {
    
    let remoteID: String
    
    var dependencyManager: VDependencyManager?
        
    init(id: String) {
        remoteID = id
    }
    
    /// Returns a properly configured Interstitial subclass
    ///
    /// :param: info A dictionary representing the interstitial
    class func configuredInterstitial(info: [String : AnyObject]) -> Interstitial? {
        var interstitial: Interstitial?
        if let type = info["type"] as? String, id = info["id"] as? String {
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
        if let remoteID = remoteID.toInt() {
            return remoteID
        }
        return 0
    }
}

// Equatable conformance
func ==(lhs: Interstitial, rhs: Interstitial) -> Bool {
    return lhs.remoteID == rhs.remoteID
}
