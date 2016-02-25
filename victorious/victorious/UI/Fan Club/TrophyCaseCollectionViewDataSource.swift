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
    
    convenience init(dependencyManager: VDependencyManager) {
        self.init()
        self.dependencyManager = dependencyManager
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}
