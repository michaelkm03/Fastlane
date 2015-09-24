//
//  VictoriousAPISerializer.swift
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

/// A RKSerialization subclass that handles registering
/// any interstitials that it finds in the response
class VictoriousAPISerializer: NSObject, RKSerialization {
    
    static func objectFromData(data: NSData!) throws -> AnyObject {
        
        let responseObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        
        // Check if we have any interstitials to register
        if let responseObject = responseObject as? [String : AnyObject],
            interstitials = responseObject["alerts"] as? [[String : AnyObject]] {
                let parsedInterstitials = VictoriousAPISerializer.parseInterstitials(interstitials)
                if parsedInterstitials.count > 0 {
                    dispatch_async(dispatch_get_main_queue()) {
                        InterstitialManager.sharedInstance.registerInterstitials(parsedInterstitials)
                    }
                }
        }
        
        return responseObject
    }
    
    static func dataFromObject(object: AnyObject!) throws -> NSData {
        return try NSJSONSerialization.dataWithJSONObject(object, options: [])
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
        if let levelInfo = paramsDict["level"] as? [String : AnyObject],
           let levelNumber = levelInfo["number"] as? Int,
           let title = paramsDict["title"] as? String,
           let description = paramsDict["description"] as? String,
           let icons = (paramsDict["icons"] as? [String])?.flatMap({ NSURL(string: $0) }),
           let videoURLString = paramsDict["backgroundVideo"] as? String,
           let videoURL = NSURL(string: videoURLString) {
            return LevelUpInterstitial(remoteID: remoteID, level: String(levelNumber), title: title, description: description, icons: icons, videoURL: videoURL)
        }
        return nil
    }
    
    /// Returns a fully-configured achievement interstitial
    ///
    /// - parameter configuration: A JSON dictionary containing all the configuration info for an achievement interstitial. If this information is invalid, this method returns nil.
    private static func achievementInterstitial( remoteID remoteID: Int, params paramsDict: [String : AnyObject] ) -> AchievementInterstitial? {
        if let levelInfo = paramsDict["level"] as? [String : AnyObject],
            let levelNumber = levelInfo["number"] as? Int,
            let progressPercentage = levelInfo["progressPercentage"] as? Int,
            let title = paramsDict["title"] as? String,
            let description = paramsDict["description"] as? String,
            let iconString = paramsDict["icon"] as? String,
            let iconURL = NSURL(string: iconString){
                return AchievementInterstitial(remoteID: remoteID, level: levelNumber, progressPercentage: progressPercentage, title: title, description: description, icon: iconURL)
        }
        return nil
    }
}
