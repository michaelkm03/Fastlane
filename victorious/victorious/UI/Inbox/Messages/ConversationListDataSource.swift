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
    
    init( dependencyManager: VDependencyManager ) {
        self.dependencyManager = dependencyManager
    }
    
    func loadConversations( pageType: VPageType, completion:((NSError?)->())? = nil ) {
        self.loadPage( pageType,
            createOperation: {
                return ConversationListOperation()
            },
            completion: { (operation, error) in
                completion?(error)
            }
        )
    }
    
    func refreshLocal() {
        // Populates the view with newly added conversations upon observing the change
        guard let userID = VCurrentUser.user()?.remoteId.integerValue else {
            return
        }
        self.refreshLocal( createOperation: {
            return FetchConverationListOperation(userID: userID)
        })
    }
    
    // MARK: - UITableViewDataSource
    
    func registerCells( tableView: UITableView ) {
        let identifier = VConversationCell.suggestedReuseIdentifier()
        let nib = UINib(nibName: identifier, bundle: NSBundle(forClass: VConversationCell.self) )
        tableView.registerNib(nib, forCellReuseIdentifier: identifier)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleItems.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72.0
    }
    
    func tableView( tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath ) -> UITableViewCell {
        let identifier = VConversationCell.suggestedReuseIdentifier()
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! VConversationCell
        let conversation = visibleItems[ indexPath.row ] as! VConversation
        cell.conversation = conversation
        cell.dependencyManager = self.dependencyManager
        cell.backgroundColor = conversation.isRead!.boolValue ? UIColor.whiteColor() : UIColor(red: 0.90, green: 0.91, blue: 0.93, alpha: 1.0)
        return cell
    }
}
