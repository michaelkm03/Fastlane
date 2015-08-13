//
//  VTrendingShelfCollectionViewCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class VTrendingShelfCollectionViewCell: VBaseCollectionViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var metadataContainer: UIView!
    
    var shelf: VShelf? {
        didSet {
            self.onShelfSet()
        }
    }
    
    var dependencyManager : VDependencyManager? {
        didSet {
            self.onDependencyManagerSet()
        }
    }
    
    func onDependencyManagerSet() {}
    
    func onShelfSet() {
        if let streamItems = shelf?.stream?.streamItems {
            if let streamItems = streamItems.array as? [VStreamItem] {
                for streamItem in streamItems {
                    collectionView.registerClass(VTrendingShelfContentCollectionViewCell.self, forCellWithReuseIdentifier: VTrendingShelfContentCollectionViewCell.reuseIdentifierForStreamItem(streamItem, baseIdentifier: nil, dependencyManager: dependencyManager))
                }
            }
        }

        self.collectionView.reloadData()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

extension VTrendingShelfCollectionViewCell : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let streamItem = shelf?.stream?.streamItems.objectAtIndex(indexPath.row) as? VStreamItem {
            let identifier = VTrendingShelfContentCollectionViewCell.reuseIdentifierForStreamItem(streamItem, baseIdentifier: nil, dependencyManager: dependencyManager)
            let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! UICollectionViewCell
            if let cell = cell as? VTrendingShelfContentCollectionViewCell {
                cell.streamItem = streamItem
                cell.backgroundColor = UIColor.redColor()
            }
            return cell
        }
        assertionFailure("VTrendingShelfCollectionViewCell was asked to display an object that isn't a stream item.")
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let streamItems = shelf?.stream?.streamItems {
            return streamItems.count
        }
        return 0
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
}

extension VTrendingShelfCollectionViewCell : UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 15, 15, 15)
    }
    
}