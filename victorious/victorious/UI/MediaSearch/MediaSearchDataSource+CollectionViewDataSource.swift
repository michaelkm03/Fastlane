//
//  MediaSearchDataSource+Collection.swift
//  victorious
//
//  Created by Patrick Lynch on 7/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

extension MediaSearchDataSource : UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sections.count == 0 ? 1 : self.sections[ section ].count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.sections.count == 0 ? 1 : self.sections.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if self.sections.count == 0,
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier( MediaSearchNoContentCell.ReuseIdentifier, forIndexPath: indexPath ) as? MediaSearchNoContentCell {
                self.configureNoContentCell( cell, forState: self.state )
                return cell
        }
        
        let section = self.sections[ indexPath.section ]
        let resultObject = section.results[ indexPath.row ]
        if section.isFullSize,
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier( MediaSearchPreviewCell.ReuseIdentifier, forIndexPath: indexPath ) as? MediaSearchPreviewCell {
                cell.previewAssetUrl = resultObject.thumbnailImageURL
                cell.assetUrl = resultObject.thumbnailImageURL
                return cell
       
        } else if let cell = collectionView.dequeueReusableCellWithReuseIdentifier( MediaSearchResultCell.ReuseIdentifier, forIndexPath: indexPath ) as? MediaSearchResultCell {
            cell.assetUrl = resultObject.thumbnailImageURL
            
            if let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems() {
                cell.selected = indexPathsForSelectedItems.contains( indexPath )
            }
            return cell
        }

        fatalError( "Could not find cell." ) 
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if indexPath.section == 0 {
            return collectionView.dequeueReusableSupplementaryViewOfKind( UICollectionElementKindSectionHeader, withReuseIdentifier: MediaSearchDataSource.ReuseIdentifier.AttributionHeader, forIndexPath: indexPath )
        }
        return collectionView.dequeueReusableSupplementaryViewOfKind( UICollectionElementKindSectionFooter, withReuseIdentifier: MediaSearchDataSource.ReuseIdentifier.ActivityFooter, forIndexPath: indexPath )
    }
    
    // MARK: - Helpers
    
    private func configureNoContentCell( cell: MediaSearchNoContentCell, forState state: MediaSearchDataSource.State ) {
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