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
        
        // Populates the view with newly added conversations upon observing the change
        guard let userID = VCurrentUser.user()?.remoteId.integerValue else {
            return
        }
        self.paginatedDataSource.refreshLocal( createOperation: {
            return FetchConverationListOperation(userID: userID)
        })
    }
    
    // MARK: - PaginatedDataSourceDelegate
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        let sortedArray = (newValue.array as? [VConversation] ?? []).sort { $0.postedAt.compare($1.postedAt) == .OrderedDescending }
        self.visibleItems = NSOrderedSet(array: sortedArray)
    }
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: DataSourceState, to newState: DataSourceState) {
        self.delegate?.paginatedDataSource?( paginatedDataSource, didChangeStateFrom: oldState, to: newState)
    }
    
    func decorateActivityCell( activityCell: ActivityFooterTableCell ) {
        
        let shouldShowLoadingAnimation = self.paginatedDataSource.isLoading() && visibleItems.count > 0
        activityCell.loading = shouldShowLoadingAnimation
        
        // Move separators way out of the way, effective hiding them for just this cell
        activityCell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 10000)
    }
    
    // MARK: - UITableViewDataSource
    
    func registerCells( tableView: UITableView ) {
        let identifier = VConversationCell.suggestedReuseIdentifier()
        let nib = UINib(nibName: identifier, bundle: NSBundle(forClass: VConversationCell.self) )
        tableView.registerNib(nib, forCellReuseIdentifier: identifier)
        
        let footerIdentifier = ActivityFooterTableCell.suggestedReuseIdentifier()
        let footerNib = UINib(nibName: footerIdentifier, bundle: NSBundle(forClass: ActivityFooterTableCell.self) )
        tableView.registerNib(footerNib, forCellReuseIdentifier: footerIdentifier)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return visibleItems.count
        case 1:
            return 1
        default:
            abort()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 72.0
        case 1:
            return 45.0
        default:
            abort()
        }
    }
    
    func tableView( tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath ) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let identifier = VConversationCell.suggestedReuseIdentifier()
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! VConversationCell
            let conversation = visibleItems[ indexPath.row ] as! VConversation
            cell.conversation = conversation
            cell.dependencyManager = self.dependencyManager
            let isRead = conversation.isRead?.boolValue ?? true
            cell.backgroundColor = isRead ? UIColor.clearColor() : UIColor.whiteColor()
            return cell
            
        case 1:
            let identifier = ActivityFooterTableCell.suggestedReuseIdentifier()
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! ActivityFooterTableCell
            decorateActivityCell(cell)
            return cell
            
        default:
            abort()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
}
