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
        let achievements: [Achievement] = self.dependencyManager?.arrayOfValuesOfType(Achievement.self, forKey: achievementsTempalteComponentKey) as? [Achievement] ?? []
        return achievements.sort { item1, item2 in
            item1.displayOrder < item2.displayOrder
        }
    }()
    
    private let achievementCellIdentifier = "TrophyCaseAchievementCollectionViewCell"
    static private let achievementsTempalteComponentKey = "achievements"
    
    convenience init(dependencyManager: VDependencyManager) {
        self.init()
        self.dependencyManager = dependencyManager
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPossibleAchievements.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(achievementCellIdentifier, forIndexPath: indexPath) as? TrophyCaseAchievementCollectionViewCell else {
            assertionFailure("Failed to dequeue a correct collection view cell for trophy case")
            return UICollectionViewCell()
        }
        
        cell.achievement = allPossibleAchievements[indexPath.item]
        return cell
    }
}
