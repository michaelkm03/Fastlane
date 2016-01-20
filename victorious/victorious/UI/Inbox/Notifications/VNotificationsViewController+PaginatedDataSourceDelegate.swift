//
//  VNotificationsViewController+PaginatedDataSourceDelegate.swift
//  victorious
//
//  Created by Patrick Lynch on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VNotificationsViewController: PaginatedDataSourceDelegate {
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        self.tableView.v_applyChangeInSection(0, from:oldValue, to:newValue)
    }
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: DataSourceState, to newState: DataSourceState) {
        self.updateTableView()
        
        if let activityCell = self.tableView.visibleCells.flatMap({ $0 as? ActivityFooterTableCell }).first {
            self.dataSource.decorateActivityCell( activityCell )
        }
    }
    
    func updateTableView() {
        
        self.tableView.separatorStyle = self.dataSource.visibleItems.count > 0 ? .SingleLine : .None
        let isAlreadyShowingNoContent = tableView.backgroundView == self.noContentView
        
        switch self.dataSource.state {
            
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
            self.tableView.backgroundView = nil
        }
    }
}
