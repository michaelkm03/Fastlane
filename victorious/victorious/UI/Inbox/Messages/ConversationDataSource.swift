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

class ConversationDataSource: NSObject, UITableViewDataSource, VPaginatedDataSourceDelegate {
    
    static var liveUpdateFrequency: NSTimeInterval = 5.0
    
    let sizingCell: VMessageCollectionCell = VMessageCollectionCell.v_fromNib()
    
    private lazy var paginatedDataSource: PaginatedDataSource = {
        let dataSource = PaginatedDataSource()
        dataSource.delegate = self
        return dataSource
    }()
    
    private(set) var visibleItems = NSOrderedSet() {
        didSet {
            self.delegate?.paginatedDataSource( paginatedDataSource, didUpdateVisibleItemsFrom: oldValue, to: visibleItems)
        }
    }
    
    func isLoading() -> Bool {
        return self.paginatedDataSource.isLoading()
    }
    
    var delegate: VPaginatedDataSourceDelegate?
    
    var state: VDataSourceState {
        return self.paginatedDataSource.state
    }
    
    func removeDeletedItems() {
        self.paginatedDataSource.removeDeletedItems()
    }
    
    private var hasLoadedOnce: Bool = false
    
    let dependencyManager: VDependencyManager
    let conversation: VConversation
    
    let messageCellDecorator: MessageTableCellDecorator
    
    init( conversation: VConversation, dependencyManager: VDependencyManager ) {
        self.dependencyManager = dependencyManager
        self.conversation = conversation
        self.messageCellDecorator = MessageTableCellDecorator(dependencyManager: dependencyManager)
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
        self.paginatedDataSource.refreshLocal(
            createOperation: {
                return FetchConverationOperation(userID: userID, paginator: StandardPaginator() )
            },
            completion: nil
        )
    }
    
    func loadMessages( pageType pageType: VPageType, completion:(([AnyObject]?, NSError?)->())? = nil ) {
        
        let userID: Int? = self.conversation.user?.remoteId.integerValue
        let conversationID: Int? = self.conversation.remoteId?.integerValue
        
        self.paginatedDataSource.loadPage( pageType,
            createOperation: {
                return ConversationOperation(conversationID: conversationID, userID: userID)
            },
            completion: { (results, error) in
                self.hasLoadedOnce = true
                completion?( results, error)
            }
        )
    }
    
    func refreshRemote( completion:(([AnyObject]?, NSError?)->())? = nil) {
        let userID: Int? = self.conversation.user?.remoteId.integerValue
        let conversationID: Int? = self.conversation.remoteId?.integerValue
        
        self.paginatedDataSource.refreshRemote(
            createOperation: {
                return ConversationOperation(conversationID: conversationID, userID: userID)
            },
            completion: completion
        )
    }
    
    // MARK: - VPaginatedDataSourceDelegate
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        let sortedArray = (newValue.array as? [VMessage] ?? []).sort { $0.displayOrder.compare($1.displayOrder) == .OrderedDescending }
        self.visibleItems = NSOrderedSet(array: sortedArray)
    }
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: VDataSourceState, to newState: VDataSourceState) {
        self.delegate?.paginatedDataSource?( paginatedDataSource, didChangeStateFrom: oldState, to: newState)
    }
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didReceiveError error: NSError) {
        self.delegate?.paginatedDataSource( paginatedDataSource, didReceiveError: error)
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
        messageCellDecorator.decorateCell( cell, withMessage: message )
        return cell
    }
}

struct MessageTableCellDecorator {
    
    let dependencyManager: VDependencyManager
    
    private func decorateCell( cell: VMessageCell, withMessage message: VMessage ) {
        cell.timeLabel?.text = message.postedAt.stringDescribingTimeIntervalSinceNow() ?? ""
        cell.messageTextAndMediaView?.text = message.text
        cell.messageTextAndMediaView?.message = message
        cell.profileImageView?.tintColor = self.dependencyManager.colorForKey(VDependencyManagerLinkColorKey)
        cell.profileImageOnRight = message.sender.isCurrentUser() ?? false
        cell.selectionStyle = .None
        
        if let urlString = message.sender.pictureUrl, let imageURL = NSURL(string: urlString) {
            cell.profileImageView?.setProfileImageURL(imageURL)
        }
    }
}
