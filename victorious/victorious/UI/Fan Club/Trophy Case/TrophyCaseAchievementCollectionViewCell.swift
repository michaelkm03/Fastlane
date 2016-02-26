//
//  TrophyCaseAchievementCollectionViewCell.swift
//  victorious
//
//  Created by Tian Lan on 2/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class TrophyCaseAchievementCollectionViewCell: UICollectionViewCell {
    
    var achievement: Achievement? {
        didSet {
            if let achievement = self.achievement {
                configureCellWithAchievement(achievement)
            }
        }
    }
    
    private func configureCellWithAchievement(achievement: Achievement) {
        
    }
}
