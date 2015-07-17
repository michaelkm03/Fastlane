//
//  GIFSearchDataSource+Collection.swift
//  victorious
//
//  Created by Patrick Lynch on 7/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

extension GIFSearchDataSource : UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sections.count == 0 ? 1 : self.sections[ section ].count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.sections.count == 0 ? 1 : self.sections.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if self.sections.count == 0 {
            if let cell = collectionView.dequeueReusableCellWithReuseIdentifier( GIFSearchNoContentCell.suggestedReuseIdentifier, forIndexPath: indexPath ) as? GIFSearchNoContentCell {
                self.configureNoContentCell( cell, forState: self.state )
                return cell
            }
        }
        
        let section = self.sections[ indexPath.section ]
        let result = section.results[ indexPath.row ]
        if section.isFullSize {
            if let cell = collectionView.dequeueReusableCellWithReuseIdentifier( GIFSearchPreviewCell.suggestedReuseIdentifier, forIndexPath: indexPath ) as? GIFSearchPreviewCell {
                cell.assetUrl = NSURL(string: result.mp4Url)
                return cell
            }
        }
        else if let cell = collectionView.dequeueReusableCellWithReuseIdentifier( GIFSearchResultCell.suggestedReuseIdentifier, forIndexPath: indexPath ) as? GIFSearchResultCell {
            cell.assetUrl = NSURL(string: result.thumbnailStillUrl)
            cell.selected = NSSet(array: collectionView.indexPathsForSelectedItems() ).containsObject( indexPath )
            return cell
        }
        fatalError( "Could not find cell." ) 
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if let attributionView = collectionView.dequeueReusableSupplementaryViewOfKind( UICollectionElementKindSectionHeader, withReuseIdentifier: GIFSearchDataSource.ReuseIdentifier.AttributionHeader, forIndexPath: indexPath ) as? UICollectionReusableView where indexPath.section == 0 {
            return attributionView
        }
        
        if let activityFooterView = collectionView.dequeueReusableSupplementaryViewOfKind( UICollectionElementKindSectionFooter, withReuseIdentifier: GIFSearchDataSource.ReuseIdentifier.ActivityFooter, forIndexPath: indexPath ) as? UICollectionReusableView {
            return activityFooterView
        }
        
        fatalError( "Could not find cell." )
    }
    
    // MARK: - Helpers
    
    private func configureNoContentCell( cell: GIFSearchNoContentCell, forState state: GIFSearchDataSource.State ) {
        switch state {
        case .Loading:
            cell.text = ""
            cell.loading = true
        case .Error:
            cell.text = "Error loading results. :("
            cell.loading = false
        case .Content where self.sections.count == 0:
            cell.loading = false
            cell.text = {
                if let searchText = self.mostRecentSearchText {
                    return "No results for \"\(searchText)\" :("
                } else  {
                    return "No results :("
                }
            }()
        default:
            cell.text = ""
            cell.loading = false
        }
    }
}