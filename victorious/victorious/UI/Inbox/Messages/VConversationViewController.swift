//
//  VConversationViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 1/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VConversationViewController: PaginatedDataSourceDelegate {
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {        
        //self.tableView.v_applyChangeInSection(0, from:oldValue, to:newValue)
        self.tableView.reloadData()
    }
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: DataSourceState, to newState: DataSourceState) {
        self.updateTableView()
    }
}

extension VConversationViewController {
    
    // MARK: - Public
    
    func updateTableView() {

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
    
    func onConversationFlagged() {
        self.endLiveUpdates()
    }
    
    // MARK: - Managing scroll position
    
    func maintainVisualScrollFromOffset(offset: CGPoint, contentSize: CGSize) {
        let newContentSize = self.tableView.contentSize
        let newOffset = CGPoint(x: 0, y: offset.y + (newContentSize.height - contentSize.height) )
        self.tableView.setContentOffset(newOffset, animated:false)
    }
    
    func scrollToBottomAnimated(animated: Bool) {
        let height = self.tableView.contentSize.height + self.tableView.contentInset.top + self.tableView.contentInset.bottom - CGRectGetHeight(self.tableView.bounds)
        let yValue = max(height, 0)
        let offset = CGPoint(x: 0, y: yValue)
        self.tableView.setContentOffset(offset, animated:animated)
    }
    
    // MARK: - Live Update
    
    func beginLiveUpdates() {
        self.timer = VTimerManager.scheduledTimerManagerWithTimeInterval( ConversationDataSource.liveUpdateFrequency,
            target: self,
            selector: Selector("onUpdate"),
            userInfo: nil,
            repeats: true
        )
    }
    
    func endLiveUpdates() {
        self.timer?.invalidate()
    }
    
    func onUpdate() {
        self.dataSource.refreshRemote() { (results, error) in
            if !results.isEmpty {
                self.scrollToBottomAnimated( self.viewHasAppeared )
            }
        }
    }
}