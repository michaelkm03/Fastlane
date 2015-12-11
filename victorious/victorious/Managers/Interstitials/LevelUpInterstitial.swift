//
//  LevelUpInterstitial.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

struct FanLoyalty {
    let level: Int
    let progressPercentage: Int
    
    init(level: Int, progressPercentage: Int) {
        self.level = level
        self.progressPercentage = progressPercentage
    }
    
    init?(dictionary: [String: AnyObject]?) {
        if let level = dictionary?["level"] as? Int,
            let progressPercentage = dictionary?["progress"] as? Int {
                self.init(level: level, progressPercentage: progressPercentage)
        } else {
            return nil
        }
    }
}

/// An interstitial that represents the level up screen
struct LevelUpInterstitial: Interstitial {
    
    let remoteID: Int
    let fanLoyalty: FanLoyalty
    let title: String
    let description: String
    let icons: [NSURL]
    let videoURL: NSURL
    
    init(remoteID: Int, fanLoyalty: FanLoyalty, title: String, description: String, icons: [NSURL], videoURL: NSURL) {
        self.remoteID = remoteID
        self.fanLoyalty = fanLoyalty
        self.title = title
        self.description = description
        self.icons = icons
        self.videoURL = videoURL
    }
    
    func viewControllerToPresent(dependencyManager dependencyManager: VDependencyManager) -> InterstitialViewController? {
        if let levelUpVC = dependencyManager.levelUpViewController(self) as? InterstitialViewController {
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