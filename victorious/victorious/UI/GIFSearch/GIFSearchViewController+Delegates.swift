//
//  GIFSearchViewController+Delegates.swift
//  victorious
//
//  Created by Patrick Lynch on 7/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

extension GIFSearchViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.clearSearch()
        self.performSearch( searchBar.text )
        searchBar.resignFirstResponder()
    }
}

extension GIFSearchViewController : UIScrollViewDelegate {
    
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

extension GIFSearchViewController : VScrollPaginatorDelegate {
    
    func shouldLoadNextPage() {
        if let searchText = self.searchBar.text {
            self.performSearch(searchText, pageType: .Next)
        }
    }
}

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