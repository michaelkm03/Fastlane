//
//  LevelUpInterstitial.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// An interstitial that represents the level up screen
class LevelUpInterstitial: Interstitial {
    
    var level: String?
    var title: String?
    var description: String?
    var icons: [String]?
    var videoURL: String?

    private var allRequiredInfoIsPresent: Bool {
        return level != nil && title != nil && description != nil && icons != nil
    }
    
    /// MARK: InterstitialConfiguration
    
    override func configureWithInfo(info: [String : AnyObject]) {
        if let paramsDict = info["params"] as? [String : AnyObject] {
            if let levelInfo = paramsDict["level"] as? [String : AnyObject],
                levelNumber = levelInfo["number"] as? Int {
                    level = String(levelNumber)
            }
            title = paramsDict["title"] as? String
            description = paramsDict["description"] as? String
            icons = paramsDict["icons"] as? [String]
            videoURL = paramsDict["backgroundVideo"] as? String
        }
    }
    
    override func viewControllerToPresent() -> InterstitialViewController? {
        if let dependencyManager = dependencyManager,
            levelUpVC = dependencyManager.levelUpViewController(self) as? InterstitialViewController where allRequiredInfoIsPresent {
            return levelUpVC
        }
        
        return nil
    }
}

extension VDependencyManager {
    
    func levelUpViewController(levelUpInterstitial: LevelUpInterstitial) -> LevelUpViewController? {
        if let levelUpVC = self.templateValueOfType(LevelUpViewController.self, forKey: "levelUpScreen") as? LevelUpViewController {
            levelUpVC.levelUpInterstitial = levelUpInterstitial
            return levelUpVC
        }
        
        return nil
    }
}