//
//  VStreamCollectionViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension VStreamCollectionViewController {
    
    // MARK: - VPaginatedDataSourceDelegate

    public override func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        
        // BEFORE calling super:
        guard let contentSection = self.streamDataSource?.sectionIndexForContent()
            where contentSection < self.collectionView.numberOfSections() else {
                return
        }
        super.paginatedDataSource(paginatedDataSource, didUpdateVisibleItemsFrom: oldValue, to: newValue)
        
        // Updating focus now will resume playback of autoplay videos and GIFs when collection
        // view animations move cells in or out of view as items are inserted or deleted
        self.focusHelper.updateFocus()
    }
    
    func updateCollectionView() {
        
        let isAlreadyShowingNoContent = collectionView.backgroundView == self.noContentView
        switch self.streamDataSource?.paginatedDataSource.state ?? .Cleared {
            
        case .Error, .NoResults, .Loading where isAlreadyShowingNoContent:
            guard let collectionView = self.collectionView else {
                break
            }
            if !isAlreadyShowingNoContent {
                self.noContentView.resetInitialAnimationState()
                self.noContentView.animateTransitionIn()
            }
            collectionView.backgroundView = self.noContentView
            self.refreshControl.layer.zPosition = (collectionView.backgroundView?.layer.zPosition ?? 0) + 1
            
        default:
            self.collectionView.backgroundView = nil
        }
    }
}
