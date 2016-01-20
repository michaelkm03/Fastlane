//
//  VConversationListViewController.swift
//  victorious
//
//  Created by Michael Sena on 12/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VConversationListViewController: SearchResultsViewControllerDelegate {
    
    func showSearch() {
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectCreateMessage)
        
        let newUserSearch = UserSearchViewController.newWithDependencyManager(dependencyManager)
        newUserSearch.searchResultsDelegate = self
        presentViewController(newUserSearch, animated: true, completion: nil)
    }
    
    func searchResultsViewControllerDidSelectCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func searchResultsViewControllerDidSelectResult(result: AnyObject) {
        guard let userResult = result as? UserSearchResultObject else {
            return
        }
        
        let operation = LoadUserConversationOperation(user: userResult.sourceResult)
        operation.queue() { op in
            if let conversation = operation.loadedConversation {
                self.displayConversation(conversation, animated: true)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}

extension VConversationListViewController: PaginatedDataSourceDelegate {
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        //self.tableView.v_applyChangeInSection(0, from:oldValue, to:newValue)
        self.tableView.reloadData()
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
