//
//  GIFSearchViewController+Fullsize.swift
//  victorious
//
//  Created by Patrick Lynch on 7/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

// Methods that handle showing full size version of assets.  Designed to work with
// indexPaths so its easy to call these when a cell is selected or deselected
extension GIFSearchViewController {
    
    func showFullSize( forItemAtIndexPath indexPath: NSIndexPath ) {
        var sectionInserted: Int?
        
        self.collectionView.performBatchUpdates({
            let result = self.searchDataSource.addHighlightSection(forIndexPath: indexPath)
            sectionInserted = result.insertedSection
            self.collectionView.applyDataSourceChanges( result )
        }, completion: nil)
        
        if let sectionInserted = sectionInserted {
            let indexPath = NSIndexPath(forRow: 0, inSection: sectionInserted)
            self.collectionView.scrollToItemAtIndexPath( indexPath, atScrollPosition: .CenteredVertically,  animated: true )
        }
    }
    
    func hideFullSize( forItemAtIndexPath indexPath: NSIndexPath ) {
        self.collectionView.performBatchUpdates({
            let result = self.searchDataSource.removeHighlightSection()
            self.collectionView.applyDataSourceChanges( result )
        }, completion: nil )
    }
}

// Conveninece method to insert/delete sections during a batch update
private extension UICollectionView {
    
    func applyDataSourceChanges( result: GIFSearchDataSource.ChangeResult ) {
        
        if let insertedSection = result.insertedSection {
            self.insertSections( NSIndexSet(index: insertedSection) )
        }
        if let deletedSection = result.deletedSection {
            self.deleteSections( NSIndexSet(index: deletedSection) )
        }
    }
}