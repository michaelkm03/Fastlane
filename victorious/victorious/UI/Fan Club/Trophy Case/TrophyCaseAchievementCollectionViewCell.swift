//
//  TrophyCaseAchievementCollectionViewCell.swift
//  victorious
//
//  Created by Tian Lan on 2/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class TrophyCaseAchievementCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    
    var achievement: Achievement? {
        didSet {
            if let achievement = self.achievement {
                configureCellWithAchievement(achievement)
            }
        }
    }
    
    private func configureCellWithAchievement(achievement: Achievement) {
        titleLabel.text = achievement.title
        if let iconImage = achievement.iconImage {
            iconImageView.image = iconImage
        }
    }
    
    func updateAchievement() {
        configureCellWithAchievement(self.achievement!)
    }
}
