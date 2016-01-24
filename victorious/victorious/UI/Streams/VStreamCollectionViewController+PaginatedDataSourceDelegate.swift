//
//  VStreamCollectionViewController+PaginatedDataSourceDelegate.swift
//  victorious
//
//  Created by Patrick Lynch on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension VStreamCollectionViewController {
    
    // MARK: - PaginatedDataSourceDelegate

    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        guard let contentSection = self.streamDataSource?.sectionIndexForContent() else {
            return
        }
        // FIXME: self.collectionView.v_applyChangeInSection(contentSection, from:oldValue, to:newValue)
        self.collectionView.reloadData()
    }
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: DataSourceState, to newState: DataSourceState) {
        
        let isAlreadyShowingNoContent = collectionView.backgroundView == self.noContentView
        
        switch newState {
            
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
