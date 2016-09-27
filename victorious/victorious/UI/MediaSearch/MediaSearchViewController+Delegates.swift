//
//  MediaSearchViewController+Delegates.swift
//  victorious
//
//  Created by Patrick Lynch on 7/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

extension MediaSearchViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        self.scrollPaginator.scrollViewDidScroll( scrollView )
        
        if !self.isScrollViewDecelerating && self.searchBar.isFirstResponder {
            self.searchBar.resignFirstResponder()
        }
        
        self.isScrollViewDecelerating = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.isScrollViewDecelerating = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.isScrollViewDecelerating = false
    }
}

extension MediaSearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.cellForItem( at: indexPath ) is MediaSearchResultCell {
            if self.options.showPreview {
                showPreview(forItemAtIndexPath: indexPath)
            } else {
                self.selectedIndexPath = indexPath
                selectAndExport(itemAtIndexPath: indexPath)
            }
            
        } else if collectionView.cellForItem( at: indexPath ) is MediaSearchPreviewCell {
            selectAndExport(itemAtIndexPath: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem( at: indexPath )
        return cell is MediaSearchResultCell || cell is MediaSearchPreviewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.tintColor = self.dependencyManager?.colorForKey( VDependencyManagerLinkColorKey )
    }
    
    // MARK: - Private
    
    func showPreview( forItemAtIndexPath indexPath: IndexPath ) {
        if self.selectedIndexPath == indexPath {
            self.hidePreviewForResult( indexPath )
            collectionView.deselectItem(at: indexPath, animated: true)
        } else {
            self.showPreviewForResult( indexPath )
        }
    }
    
    func selectAndExport( itemAtIndexPath indexPath: IndexPath ) {
        self.continueWithSelectedItem(nil)
        self.selectCellAtSelectedIndexPath() //< Selects the cell that was selected before this preview cell
        dispatch_after(0.0) {
            self.selectCellAtSelectedIndexPath() //< Ensures it remains selected
        }
    }
}
