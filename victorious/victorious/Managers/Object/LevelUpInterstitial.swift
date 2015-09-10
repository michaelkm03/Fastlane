//
//  LevelUpInterstitial.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class LevelUpInterstitial: Interstitial {
    
    var level: String?
    var title: String?
    var description: String?
    var icons: [String]?
    var videoURL: String?
    
    /// MARK: InterstitialConfiguration
    
    override func configureWithInfo(info: [String : AnyObject]) {
        
    }
    
    override func viewControllerToPresent() -> InterstitialViewController? {
        if let dependencyManager = dependencyManager, levelUpVC = dependencyManager.levelUpViewController() as? InterstitialViewController {
            return levelUpVC
        }
        
        return nil
    }
}

extension VDependencyManager {
    
    func levelUpViewController() -> LevelUpViewController? {
        if let levelUpVC = self.templateValueOfType(LevelUpViewController.self, forKey: "levelUpScreen") as? LevelUpViewController {
            return levelUpVC
        }
        
        return nil
    }
}