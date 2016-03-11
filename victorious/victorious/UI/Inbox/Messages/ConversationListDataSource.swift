//
//  ConversationListDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 1/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ConversationListDataSource: PaginatedDataSource, UITableViewDataSource {
    
    let dependencyManager: VDependencyManager
    
    let activityFooterDataSource = ActivityFooterTableDataSource()
    
    init( dependencyManager: VDependencyManager ) {
        self.dependencyManager = dependencyManager
    }
    
    func loadConversations( pageType: VPageType, completion:((NSError?)->())? = nil ) {
        self.loadPage( pageType,
            createOperation: {
                return ConversationListOperation()
            },
            completion: { (results, error, cancelled) in
                completion?(error)
            }
        )
    }
    
    func refreshLocal( completion completion: (([AnyObject]?)->())? = nil) {
        self.loadNewItems( createOperation: {
            let op = ConversationListOperation()
            op.localFetch = true
            return op
        },
        completion: { results, error, cancelled in
            completion?(results)
        })
    }
    
    func refreshRemote( completion:(([AnyObject]?, NSError?, Bool)->())? = nil) {
        self.loadNewItems(
            createOperation: {
                return ConversationListOperation()
            },
            completion: completion
        )
    }
    
    func redocorateVisibleCells(tableView: UITableView) {
        for indexPath in tableView.indexPathsForVisibleRows ?? [] {
            guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? VConversationCell else {
                continue
            }
            self.decorate(cell: cell, atIndexPath: indexPath)
        }
    }
    
    func registerCells( tableView: UITableView ) {
        let identifier = VConversationCell.suggestedReuseIdentifier()
        let nib = UINib(nibName: identifier, bundle: NSBundle(forClass: VConversationCell.self) )
        tableView.registerNib(nib, forCellReuseIdentifier: identifier)
        
        activityFooterDataSource.registerCells(tableView)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.visibleItems.count
        } else {
            return activityFooterDataSource.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 72.0
        } else {
            return activityFooterDataSource.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    func tableView( tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath ) -> UITableViewCell {
        if indexPath.section == 0 {
            let identifier = VConversationCell.suggestedReuseIdentifier()
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! VConversationCell
            decorate(cell: cell, atIndexPath: indexPath)
            return cell
            
        } else {
            return activityFooterDataSource.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    private func decorate(cell conversationCell:VConversationCell, atIndexPath indexPath: NSIndexPath) {
        let conversation = visibleItems[ indexPath.row ] as! VConversation
        conversationCell.conversation = conversation
        conversationCell.dependencyManager = self.dependencyManager
        conversationCell.backgroundColor = conversation.isRead!.boolValue ? UIColor.whiteColor() : UIColor(red: 0.90, green: 0.91, blue: 0.93, alpha: 1.0)
    }
}
