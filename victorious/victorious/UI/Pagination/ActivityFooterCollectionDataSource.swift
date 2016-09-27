//
//  ActivityFooterCollectionDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 2/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ActivityFooterCollectionDataSource: NSObject, UICollectionViewDataSource {
    
    let identifier = "ActivityIndicatorCollectionCell"
    
    weak fileprivate var cell: UICollectionViewCell? {
        didSet {
            cell?.hidden = hidden
        }
    }
    
    var hidden: Bool = true {
        didSet {
            cell?.hidden = hidden
        }
    }
    
    func collectionView( _ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath)
        self.cell = cell
        return cell
    }
    
    func registerCells( _ collectionView: UICollectionView ) {
        let nib = UINib(nibName: identifier, bundle: Bundle(forClass: ActivityIndicatorCollectionCell.self) )
        collectionView.registerNib(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let height: CGFloat = self.hidden ? 0.0 : 50.0
        return CGSize(width: collectionView.bounds.width, height: height)
    }
}
