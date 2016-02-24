//
//  TrophyCaseCollectionViewDataSource.swift
//  victorious
//
//  Created by Tian Lan on 2/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class TrophyCaseCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}
