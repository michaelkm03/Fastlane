//
//  ConversationListDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 1/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ConversationListDataSource: NSObject, UITableViewDataSource, PaginatedDataSourceDelegate {
    
    private lazy var paginatedDataSource: PaginatedDataSource = {
        let dataSource = PaginatedDataSource()
        dataSource.delegate = self
        return dataSource
    }()
    
    let dependencyManager: VDependencyManager
    
    var delegate: PaginatedDataSourceDelegate?
    
    init( dependencyManager: VDependencyManager ) {
        self.dependencyManager = dependencyManager
        super.init()
        
        self.KVOController.observe( VCurrentUser.user()!,
            keyPath: "conversations",
            options: [.New, .Old],
            action: Selector("onConversationsChanged:")
        )
    }
    
    private(set) var visibleItems = NSOrderedSet() {
        didSet {
            self.delegate?.paginatedDataSource( paginatedDataSource, didUpdateVisibleItemsFrom: oldValue, to: visibleItems)
        }
    }
    
    var state: DataSourceState {
        return self.paginatedDataSource.state
    }
    
    func loadConversations( pageType: VPageType, completion:((NSError?)->())? = nil ) {
        self.paginatedDataSource.loadPage( pageType,
            createOperation: {
                return ConversationListOperation()
            },
            completion: { (operation, error) in
                completion?(error)
            }
        )
    }
    
    func onConversationsChanged( change: [NSObject : AnyObject]? ) {
        self.paginatedDataSource.refreshLocal() {
            return ConversationListOperation()
        }
    }
    
    // MARK: - PaginatedDataSourceDelegate
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        
        let sortedArray = (newValue.array as? [VConversation] ?? []).sort { $0.postedAt.compare($1.postedAt) == .OrderedDescending }
        self.visibleItems = NSOrderedSet(array: sortedArray)
    }
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: DataSourceState, to newState: DataSourceState) {
        self.delegate?.paginatedDataSource?( paginatedDataSource, didChangeStateFrom: oldState, to: newState)
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
    
    func tableView( tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath ) -> UITableViewCell {
        let identifier = VConversationCell.suggestedReuseIdentifier()
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! VConversationCell
        let conversation = visibleItems[ indexPath.row ] as! VConversation
        cell.conversation = conversation
        cell.dependencyManager = self.dependencyManager
        let isRead = conversation.isRead?.boolValue ?? true
        cell.backgroundColor = isRead ? UIColor.clearColor() : UIColor.whiteColor()
        return cell
    }
}
