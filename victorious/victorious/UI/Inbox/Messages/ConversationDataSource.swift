//
//  ConversationDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 1/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import KVOController

class ConversationDataSource: NSObject, UITableViewDataSource, PaginatedDataSourceDelegate {
    
    private lazy var paginatedDataSource: PaginatedDataSource = {
        let dataSource = PaginatedDataSource()
        dataSource.delegate = self
        return dataSource
    }()
    
    let dependencyManager: VDependencyManager
    let conversation: VConversation
    
    var delegate: PaginatedDataSourceDelegate?
    
    init( conversation: VConversation, dependencyManager: VDependencyManager ) {
        self.dependencyManager = dependencyManager
        self.conversation = conversation
    }
    
    private(set) var visibleItems = NSOrderedSet() {
        didSet {
            self.delegate?.paginatedDataSource( paginatedDataSource, didUpdateVisibleItemsFrom: oldValue, to: visibleItems)
        }
    }
    
    var state: DataSourceState {
        return self.paginatedDataSource.state
    }
    
    func loadMessages( pageType pageType: VPageType, completion:((NSError?)->())? = nil ) {
        self.paginatedDataSource.loadPage( pageType,
            createOperation: {
                return ConversationOperation(conversationID: self.conversation.remoteId.integerValue)
            },
            completion: { (operation, error) in
                completion?(error)
            }
        )
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
    
    // MARK: - PaginatedDataSourceDelegate
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        /*let sortedArray = (newValue.array as? [VMessage] ?? []).sort { $0.postedAt?.compare($1.postedAt) == .OrderedAscending }
        self.visibleItems = NSOrderedSet(array: sortedArray)*/
        self.visibleItems = newValue
    }
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: DataSourceState, to newState: DataSourceState) {
        self.delegate?.paginatedDataSource?( paginatedDataSource, didChangeStateFrom: oldState, to: newState)
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
