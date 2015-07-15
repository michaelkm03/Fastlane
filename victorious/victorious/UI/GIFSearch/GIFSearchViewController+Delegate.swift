//
//  GIFSearchViewController+Delegate.swift
//  victorious
//
//  Created by Patrick Lynch on 7/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

extension GIFSearchViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let section = self.searchDataSource.sections[ indexPath.section ]
        if collectionView.cellForItemAtIndexPath( indexPath ) is GIFSearchResultCell {
            if self.selectedIndexPath == indexPath {
                self.hidePreviewForResult( indexPath )
            }
            else {
                self.showPreviewForResult( indexPath )
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return collectionView.cellForItemAtIndexPath( indexPath ) is GIFSearchResultCell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        cell.tintColor = self.dependencyManager?.colorForKey( VDependencyManagerLinkColorKey )
    }
}