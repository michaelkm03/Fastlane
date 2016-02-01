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
        // TODO: Let's try to use the commented out version instead of reloadData
        
//        guard let contentSection = self.streamDataSource?.sectionIndexForContent()
//            where contentSection < self.collectionView.numberOfSections() else {
//                return
//        }
//        self.collectionView.v_applyChangeInSection(contentSection, from:oldValue, to:newValue)
        collectionView.reloadData()
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
