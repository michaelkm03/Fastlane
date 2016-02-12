//
//  VConversationListViewController.swift
//  victorious
//
//  Created by Michael Sena on 12/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VConversationListViewController {
    
    func showSearch() {
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectCreateMessage)
        
        let newUserSearch = UserSearchViewController.newWithDependencyManager(dependencyManager)
        newUserSearch.searchResultsDelegate = self
        presentViewController(newUserSearch, animated: true, completion: nil)
    }
}

extension VConversationListViewController: SearchResultsViewControllerDelegate {

    func searchResultsViewControllerDidSelectCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func searchResultsViewControllerDidSelectResult(result: AnyObject) {
        guard let userResult = result as? UserSearchResultObject else {
            return
        }
        
        let operation = LoadUserConversationOperation(sourceUser: userResult.sourceResult)
        operation.queue() { op in
            if let conversation = operation.loadedConversation {
                self.showConversation(conversation, animated: true)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}

extension VConversationListViewController: PaginatedDataSourceDelegate {
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        self.tableView.v_applyChangeInSection(0, from:oldValue, to:newValue, animated: self.shouldAnimateDataSourceChanges)
        self.shouldAnimateDataSourceChanges = falsegit 
    }
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: DataSourceState, to newState: DataSourceState) {
        self.updateTableView()
        
        let wasHidden = dataSource.activityFooterDataSource.hidden
        let canScroll = tableView.contentSize.height > tableView.bounds.height
        let shouldHide = !paginatedDataSource.shouldShowNextPageActivity || !canScroll
        dataSource.activityFooterDataSource.hidden = shouldHide
        if wasHidden != shouldHide {
            tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
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

