//
//  NotificationsDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class NotificationsDataSource: PaginatedDataSource, UITableViewDataSource {
    
    let dependencyManager: VDependencyManager
    
    required init( dependencyManager: VDependencyManager ) {
        self.dependencyManager = dependencyManager
    }
    
    func loadNotifications( pageType: VPageType, completion: ((NSError?) -> ())? = nil ) {
        self.loadPage( pageType,
            createOperation: {
                return NotificationsOperation()
            },
            completion: { (results, error, cancelled) in
                completion?(error)
            }
        )
    }
    
    func refreshRemote( completion: (([AnyObject]?, NSError?, Bool) -> ())? = nil) {
        self.loadNewItems(
            createOperation: {
                return NotificationsOperation()
            },
            completion: completion
        )
    }
    
    // MARK: - UITableViewDataSource
    
    func registerCells( tableView: UITableView ) {
        let identifier = "NotificationCell"
        let nib = UINib(nibName: identifier, bundle: NSBundle(forClass:self.dynamicType) )
        tableView.registerNib( nib, forCellReuseIdentifier: identifier)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleItems.count
    }
    
    func tableView( tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationCell", forIndexPath: indexPath) as! NotificationCell
        decorate(cell: cell, atIndexPath: indexPath)
        return cell
    }
    
    func decorate(cell notificationCell: NotificationCell, atIndexPath indexPath: NSIndexPath) {
        let notification = visibleItems[ indexPath.row ] as! VNotification
        notificationCell.updateContent(with: notification, dependencyManager: dependencyManager)
    }
    
    
}
