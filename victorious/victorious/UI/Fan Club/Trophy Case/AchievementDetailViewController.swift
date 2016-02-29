//
//  AchievementDetailViewController.swift
//  victorious
//
//  Created by Tian Lan on 2/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import UIKit

class AchievementDetailViewController: UIViewController {
    
    @IBOutlet private weak var dismissButton: UIButton!
    @IBOutlet private weak var achievementTitleLabel: UILabel!
    @IBOutlet private weak var achievementDetailLabel: UILabel!
    @IBOutlet private weak var confirmationButton: UIButton!
    
    var achievement: Achievement?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let achievement = achievement else {
            return
        }
        achievementTitleLabel.text = achievement.title
        achievementDetailLabel.text = achievement.detailedDescription
    }
}