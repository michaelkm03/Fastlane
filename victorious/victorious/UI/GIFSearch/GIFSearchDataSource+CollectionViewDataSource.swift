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
        if self.sections.count == 0,
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier( GIFSearchNoContentCell.ReuseIdentifier, forIndexPath: indexPath ) as? GIFSearchNoContentCell {
                self.configureNoContentCell( cell, forState: self.state )
                return cell
        }
        
        let section = self.sections[ indexPath.section ]
        let resultObject = section.results[ indexPath.row ]
        if section.isFullSize,
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier( GIFSearchPreviewCell.ReuseIdentifier, forIndexPath: indexPath ) as? GIFSearchPreviewCell {
                cell.previewAssetUrl = NSURL(string: resultObject.sourceResult.thumbnailStillURL)
                cell.assetUrl = NSURL(string: resultObject.sourceResult.mp4URL)
                return cell
       
        } else if let cell = collectionView.dequeueReusableCellWithReuseIdentifier( GIFSearchResultCell.ReuseIdentifier, forIndexPath: indexPath ) as? GIFSearchResultCell {
            cell.assetUrl = NSURL(string: resultObject.sourceResult.thumbnailStillURL)
            
            if let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems() {
                cell.selected = indexPathsForSelectedItems.contains( indexPath )
            }
            return cell
        }

        fatalError( "Could not find cell." ) 
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if indexPath.section == 0 {
            return collectionView.dequeueReusableSupplementaryViewOfKind( UICollectionElementKindSectionHeader, withReuseIdentifier: GIFSearchDataSource.ReuseIdentifier.AttributionHeader, forIndexPath: indexPath )
        }
        return collectionView.dequeueReusableSupplementaryViewOfKind( UICollectionElementKindSectionFooter, withReuseIdentifier: GIFSearchDataSource.ReuseIdentifier.ActivityFooter, forIndexPath: indexPath )
    }
    
    // MARK: - Helpers
    
    private func configureNoContentCell( cell: GIFSearchNoContentCell, forState state: GIFSearchDataSource.State ) {
        switch state {
        case .Loading:
            cell.text = ""
            cell.loading = true
        case .Error:
            cell.text = NSLocalizedString( "Error loading results", comment:"" )
            cell.loading = false
        case .Content where self.sections.count == 0:
            cell.loading = false
            cell.text = {
                return NSLocalizedString( "No results", comment:"" )
            }()
        default:
            cell.text = ""
            cell.loading = false
        }
    }
}