//
//  ConversationDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 1/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

class ConversationDataSource: PaginatedDataSource, UITableViewDataSource {
    
    static var liveUpdateFrequency: NSTimeInterval = 5.0
    
    private var hasLoadedOnce: Bool = false
    
    let dependencyManager: VDependencyManager
    let conversation: VConversation
    
    init( conversation: VConversation, dependencyManager: VDependencyManager ) {
        self.dependencyManager = dependencyManager
        self.conversation = conversation
        super.init()
        
        sortOrder = .OrderedDescending
    }
    
    func loadMessages( pageType pageType: VPageType, completion: (([AnyObject]?, NSError?, Bool) -> ())? = nil ) {
        let userID: Int? = self.conversation.user?.remoteId.integerValue
        let conversationID: Int? = self.conversation.remoteId?.integerValue
        
        self.loadPage( pageType,
            createOperation: {
                return ConversationOperation(conversationID: conversationID, userID: userID)
            },
            completion: { results, error, cancelled in
                self.hasLoadedOnce = true
                completion?(results, error, cancelled)
            }
        )
    }
    
    func refresh( local local: Bool = false, completion: (([AnyObject]?, NSError?, Bool) -> ())? = nil) {
        let userID: Int? = self.conversation.user?.remoteId.integerValue
        let conversationID: Int? = self.conversation.remoteId?.integerValue
        
        self.loadNewItems(
            createOperation: {
                return ConversationOperation(conversationID: conversationID, userID: userID, localFetch: local)
            },
            completion: completion
        )
    }
    
    // MARK: - UITableViewDataSource
    
    func registerCells( tableView: UITableView ) {
        let identifier = VMessageCell.suggestedReuseIdentifier()
        let nib = UINib(nibName: identifier, bundle: NSBundle(forClass: VMessageCell.self) )
        tableView.registerNib(nib, forCellReuseIdentifier: identifier)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleItems.count
    }
    
    func tableView( tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath ) -> UITableViewCell {
        let identifier = VMessageCell.suggestedReuseIdentifier()
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! VMessageCell
        let message = visibleItems[ indexPath.row ] as! VMessage
        decorateCell( cell, withMessage: message )
        return cell
    }
    
    // MARK: - Private helpers
    
    private func decorateCell( cell: VMessageCell, withMessage message: VMessage ) {
        cell.timeLabel?.text = message.postedAt.stringDescribingTimeIntervalSinceNow() ?? ""
        cell.messageTextAndMediaView?.text = message.text
        cell.messageTextAndMediaView?.message = message
        cell.profileImageOnRight = message.sender.isCurrentUser
        cell.selectionStyle = .None
        
        // VMessageCell's profile image view was removed
        // Add an image view to VMessageCell if you need
        // to display a profile image
    }
}
