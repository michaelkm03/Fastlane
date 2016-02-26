//
//  TrophyCaseCollectionViewDataSource.swift
//  victorious
//
//  Created by Tian Lan on 2/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class TrophyCaseCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    private(set) var dependencyManager: VDependencyManager?
    private lazy var allPossibleAchievements: [Achievement] = {
        return self.dependencyManager!.arrayOfValuesOfType(Achievement.self, forKey: "achievements") as! [Achievement]
    }()
    
    private struct UIConstant {
        static let achievementCellIdentifier = "TrophyCaseAchievementCollectionViewCell"
    }
    
    convenience init(dependencyManager: VDependencyManager) {
        self.init()
        self.dependencyManager = dependencyManager
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPossibleAchievements.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier(UIConstant.achievementCellIdentifier, forIndexPath: indexPath)
    }
}

class Achievement {
    
    let name: String
    let title: String
    let description: String
    let displayOrder: Int
    private(set) var iconAssets: [NSURL]?
    private(set) var dependencyManager: VDependencyManager?
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        self.name = dependencyManager.stringForKey("name")
        self.title = dependencyManager.stringForKey("title")
        self.description = dependencyManager.stringForKey("description")
        self.displayOrder = dependencyManager.numberForKey("displayOrder").integerValue
        if let assets = dependencyManager.arrayForKey("assets") as? [NSDictionary] {
            iconAssets = assets.flatMap { NSURL(string: ($0["imageUrl"] as? String)!) }
        }
    }
}