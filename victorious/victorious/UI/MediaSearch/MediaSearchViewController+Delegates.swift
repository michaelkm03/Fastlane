//
//  MediaSearchViewController+Delegates.swift
//  victorious
//
//  Created by Patrick Lynch on 7/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

extension MediaSearchViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        self.scrollPaginator.scrollViewDidScroll( scrollView )
        
        if !self.isScrollViewDecelerating && self.searchBar.isFirstResponder() {
            self.searchBar.resignFirstResponder()
        }
        
        self.isScrollViewDecelerating = true
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.isScrollViewDecelerating = false
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.isScrollViewDecelerating = false
    }
}

extension MediaSearchViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if collectionView.cellForItemAtIndexPath( indexPath ) is MediaSearchResultCell {
            if self.options.showPreview {
                showPreview(forItemAtIndexPath: indexPath)
            } else {
                self.selectedIndexPath = indexPath
                selectAndExport(itemAtIndexPath: indexPath)
            }
            
        } else if collectionView.cellForItemAtIndexPath( indexPath ) is MediaSearchPreviewCell {
            selectAndExport(itemAtIndexPath: indexPath)
        }
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let cell = collectionView.cellForItemAtIndexPath( indexPath )
        return cell is MediaSearchResultCell || cell is MediaSearchPreviewCell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        cell.tintColor = self.dependencyManager?.colorForKey( VDependencyManagerLinkColorKey )
    }
    
    // MARK: - Private
    
    func showPreview( forItemAtIndexPath indexPath: NSIndexPath ) {
        if self.selectedIndexPath == indexPath {
            self.hidePreviewForResult( indexPath )
            collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        } else {
            self.showPreviewForResult( indexPath )
        }
    }
    
    func selectAndExport( itemAtIndexPath indexPath: NSIndexPath ) {
        self.continueWithSelectedItem(nil)
        self.selectCellAtSelectedIndexPath() //< Selects the cell that was selected before this preview cell
        dispatch_after(0.0) {
            self.selectCellAtSelectedIndexPath() //< Ensures it remains selected
        }
    }
}
