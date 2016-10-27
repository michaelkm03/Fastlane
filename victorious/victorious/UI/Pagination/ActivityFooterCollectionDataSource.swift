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
    
    weak private var cell: UICollectionViewCell? {
        didSet {
            cell?.isHidden = hidden
        }
    }
    
    var hidden: Bool = true {
        didSet {
            cell?.isHidden = hidden
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        self.cell = cell
        return cell
    }
    
    func registerCells(_ collectionView: UICollectionView) {
        let nib = UINib(nibName: identifier, bundle: Bundle(for: ActivityIndicatorCollectionCell.self) )
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: hidden ? 0.0 : 50.0)
    }
}
