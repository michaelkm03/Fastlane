//
//  AlertParser.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// An enum describing each type of supported interstitials
private enum InterstitialType : String {
    case LevelUp = "levelUp"
    case Achievement = "achievement"
}

/// An object that handles registering
/// any interstitials that it finds in a response object
class AlertParser: NSObject {
    
    func parseAlerts(payload payload: [[String : AnyObject]]?) {
        // Check if we have any interstitials to register
        guard let interstitials = payload else {
            return
        }
        
        let parsedInterstitials = AlertParser.parseInterstitials(interstitials)
        if parsedInterstitials.count > 0 {
            dispatch_async(dispatch_get_main_queue()) {
                InterstitialManager.sharedInstance.registerInterstitials(parsedInterstitials)
            }
        }
    }
    
    // Class function for parsing interstitials
    private class func parseInterstitials(interstitials: [[String : AnyObject]]) -> [Interstitial] {
        
        return interstitials.flatMap() { (config: [String : AnyObject]) -> Interstitial? in
            if let remoteIDString = config["id"] as? String,
               let typeString = config["type"] as? String,
               let params = config["params"] as? [String : AnyObject],
               let remoteID = Int(remoteIDString),
               let type = InterstitialType(rawValue: typeString) {
                switch (type)
                {
                case .LevelUp:
                    return levelUpInterstitial(remoteID: remoteID, params: params)
                case .Achievement:
                    return achievementInterstitial(remoteID: remoteID, params: params)
                }
                
            }
            return nil
        }
    }
    
    /// Returns a fully-configured level-up interstitial
    ///
    /// - parameter configuration: A JSON dictionary containing all the configuration info for a level-up interstitial. If this information is invalid, this method returns nil.
    private static func levelUpInterstitial( remoteID remoteID: Int, params paramsDict: [String : AnyObject] ) -> LevelUpInterstitial? {
        if let userInfo = paramsDict["user"] as? [String : AnyObject],
            let levelInfo = userInfo["fanloyalty"] as? [String : AnyObject],
            let levelNumber = levelInfo["level"] as? Int,
            let progressPercentage = levelInfo["progress"] as? Int,
            let title = paramsDict["title"] as? String,
            let description = paramsDict["description"] as? String,
            let icons = (paramsDict["icons"] as? [String])?.flatMap({ NSURL(string: $0) }),
            let videoURLString = paramsDict["backgroundVideo"] as? String,
            let videoURL = NSURL(string: videoURLString) {
                return LevelUpInterstitial(remoteID: remoteID, level: levelNumber, progressPercentage: progressPercentage, title: title, description: description, icons: icons, videoURL: videoURL)
        }
        return nil
    }
    
    /// Returns a fully-configured achievement interstitial
    ///
    /// - parameter configuration: A JSON dictionary containing all the configuration info for an achievement interstitial. If this information is invalid, this method returns nil.
    private static func achievementInterstitial( remoteID remoteID: Int, params paramsDict: [String : AnyObject] ) -> AchievementInterstitial? {
        if let userInfo = paramsDict["user"] as? [String : AnyObject],
            let levelInfo = userInfo["fanloyalty"] as? [String : AnyObject],
            let levelNumber = levelInfo["level"] as? Int,
            let progressPercentage = levelInfo["progress"] as? Int,
            let title = paramsDict["title"] as? String,
            let icons = (paramsDict["icons"] as? [String])?.flatMap({ NSURL(string: $0) }),
            let description = paramsDict["description"] as? String {
                return AchievementInterstitial(remoteID: remoteID, level: levelNumber, progressPercentage: progressPercentage, title: title, description: description, icons: icons)
        }
        return nil
    }
}
