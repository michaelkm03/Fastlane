//
//  ConversationDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 1/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK
import KVOController

class ConversationDataSource: PaginatedDataSource, UITableViewDataSource {
    
    static var liveUpdateFrequency: NSTimeInterval = 5.0
    
    private var hasLoadedOnce: Bool = false
    
    let dependencyManager: VDependencyManager
    let conversation: VConversation
    
    init( conversation: VConversation, dependencyManager: VDependencyManager ) {
        self.dependencyManager = dependencyManager
        self.conversation = conversation
        super.init()
        
        self.KVOController.observe( conversation,
            keyPath: "messages",
            options: [],
            action: Selector("onConversationChanged:")
        )
    }
    
    func onConversationChanged( change: [NSObject : AnyObject]? ) {
        guard let userID = self.conversation.user?.remoteId?.integerValue else {
            return
        }
        
        guard hasLoadedOnce, let value = change?[ NSKeyValueChangeKindKey ] as? UInt,
            let kind = NSKeyValueChange(rawValue:value) where kind != .Removal else {
                return
        }
        self.refreshLocal(
            createOperation: {
                return FetchConverationOperation(userID: userID, paginator: StandardPaginator() )
            },
            completion: nil
        )
    }
    
    func loadMessages( pageType pageType: VPageType, completion:((NSError?)->())? = nil ) {
        guard let conversationID = self.conversation.remoteId?.integerValue else {
            return
        }
        self.loadPage( pageType,
            createOperation: {
                return ConversationOperation(conversationID: conversationID)
            },
            completion: { (operation, error) in
                self.hasLoadedOnce = true
                completion?(error)
            }
        )
    }
    
    func refreshRemote( completion:(([AnyObject], NSError?)->())? = nil) {
        if let conversationID = self.conversation.remoteId?.integerValue {
            self.refreshRemote(createOperation: {
                    return ConversationOperation(conversationID: conversationID)
                },
                completion: completion
            )
        }
    }
    
    private func decorateCell( cell: VMessageCell, withMessage message: VMessage ) {
        cell.timeLabel?.text = message.postedAt?.timeSince() ?? ""
        cell.messageTextAndMediaView?.text = message.text
        cell.messageTextAndMediaView?.message = message
        cell.profileImageView?.tintColor = self.dependencyManager.colorForKey(VDependencyManagerLinkColorKey)
        cell.profileImageOnRight = message.sender?.isCurrentUser() ?? false
        cell.selectionStyle = .None
        
        if let urlString = message.sender?.pictureUrl, let imageURL = NSURL(string: urlString) {
            cell.profileImageView?.setProfileImageURL(imageURL)
        }
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
}
