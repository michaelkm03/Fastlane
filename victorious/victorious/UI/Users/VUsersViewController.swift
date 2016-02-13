//
//  VUsersViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 1/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VUsersViewController: VPaginatedDataSourceDelegate {
    
    private func updateBackground() {
        let isAlreadyShowingNoContent = collectionView.backgroundView == self.noContentView
        
        switch self.usersDataSource.state {
            
        case .Error, .NoResults, .Loading where isAlreadyShowingNoContent:
            guard let collectionView = self.collectionView else {
                break
            }
            if !isAlreadyShowingNoContent {
                self.noContentView.resetInitialAnimationState()
                self.noContentView.animateTransitionIn()
            }
            collectionView.backgroundView = self.noContentView
            
        default:
            collectionView.backgroundView = nil
        }
    }
    
    public func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        self.collectionView.v_applyChangeInSection(0, from: oldValue, to: newValue)
    }
    
    public func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: VDataSourceState, to newState: VDataSourceState) {
        self.updateBackground()
    }
}
