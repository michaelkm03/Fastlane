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
        
        let operation = ConversationForUserOperation(sourceUser: userResult.sourceResult)
        operation.queue() { op in
            if let conversation = operation.loadedConversation {
                self.showConversation(conversation, animated: true)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}

extension VConversationListViewController: VPaginatedDataSourceDelegate {
    
    public func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        self.tableView.v_applyChangeInSection(0, from:oldValue, to:newValue, animated: self.shouldAnimateDataSourceChanges)
    }
    
    public func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: VDataSourceState, to newState: VDataSourceState) {
        self.updateTableView()
        
        let wasHidden = dataSource.activityFooterDataSource.hidden
        let canScroll = tableView.contentSize.height > tableView.bounds.height
        let shouldHide = !paginatedDataSource.shouldShowNextPageActivity || !canScroll
        dataSource.activityFooterDataSource.hidden = shouldHide
        if wasHidden != shouldHide {
            tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
        }
    }
    
    public func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didReceiveError error: NSError) {
        let viewControllerForError = self.navigationController ?? self
        viewControllerForError.v_showErrorDefaultError()
    }
    
    func updateTableView() {
        
        self.tableView.separatorStyle = self.dataSource.visibleItems.count > 0 ? .SingleLine : .None
        let isAlreadyShowingNoContent = tableView.backgroundView == self.noContentView
        
        switch self.dataSource.state {
            
        case .NoResults, .Loading where isAlreadyShowingNoContent:
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
