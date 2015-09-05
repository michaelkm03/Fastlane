//
//  LevelUpModel.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class LevelUpModel: NSObject {
    var level: String = "3"
    var icons: [String] = []
    var title: String = "Congratulations!"
    var prizeDescription: String = "You've unlocked more gifts"
    var badgeColor: UIColor = UIColor(red: 35/255, green: 187/255, blue: 177/255, alpha: 1)
}
