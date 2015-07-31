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
        if let searchBarText = searchBar.text where count(searchBarText) > 0 {
            self.performSearchWithText( searchBar.text )
            self.clearSearch()
            searchBar.resignFirstResponder()
        }
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
        if let searchText = self.searchDataSource.mostRecentSearchText {
            self.performSearchWithText( searchText, pageType: .Next)
        }
        else {
            self.loadDefaultContent(pageType: .Next)
        }
    }
}

extension GIFSearchViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if  self.searchDataSource.sections.count == 0 {
            return
        }
        let section = self.searchDataSource.sections[ indexPath.section ]
        if collectionView.cellForItemAtIndexPath( indexPath ) is GIFSearchResultCell {
            if self.selectedIndexPath == indexPath {
                self.hidePreviewForResult( indexPath )
                collectionView.deselectItemAtIndexPath(indexPath, animated: true)
            }
            else {
                self.showPreviewForResult( indexPath )
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if collectionView.cellForItemAtIndexPath( indexPath ) is GIFSearchPreviewCell {
            self.exportSelectedItem( nil )
            return false
        }
        return true
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        cell.tintColor = self.dependencyManager?.colorForKey( VDependencyManagerLinkColorKey )
    }
}