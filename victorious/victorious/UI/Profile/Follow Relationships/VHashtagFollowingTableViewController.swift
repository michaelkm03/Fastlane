//
//  VHashtagFollowingTableViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 12/20/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

extension VHashtagFollowingTableViewController: PaginatedDataSourceDelegate {
    
    func loadHashtags( pageType pageType: VPageType, completion:(NSError? -> ())? ) {
        self.paginatedDataSource.delegate = self
        self.paginatedDataSource.loadPage( pageType,
            createOperation: {
                return FollowedHashtagsOperation()
            },
            completion: { (op, error) in
                completion?(error)
            }
        )
    }
    
    private func updateBackground() {
        let isAlreadyShowingNoContent = tableView.backgroundView == self.noContentView
        
        switch self.paginatedDataSource.state {
            
        case .Error, .NoResults, .Loading where isAlreadyShowingNoContent:
            guard let tableView = self.tableView else {
                break
            }
            if !isAlreadyShowingNoContent {
                self.noContentView.resetInitialAnimationState()
                self.noContentView.animateTransitionIn()
            }
            tableView.backgroundView = self.noContentView
            
        default:
            tableView.backgroundView = nil
        }
    }

    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        self.tableView.v_applyChangeInSection(0, from: oldValue, to: newValue)
    }
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: DataSourceState, to newState: DataSourceState) {
        self.updateBackground()
    }
}
