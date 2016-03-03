//
//  NotificationsDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class NotificationsDataSource : PaginatedDataSource, UITableViewDataSource {
    
    let dependencyManager: VDependencyManager
    
    required init( dependencyManager: VDependencyManager ) {
        self.dependencyManager = dependencyManager
    }
    
    func loadNotifications( pageType: VPageType, completion:((NSError?)->())? = nil ) {
        self.loadPage( pageType,
            createOperation: {
                return NotificationsOperation()
            },
            completion: { (operation, error) in
                completion?(error)
            }
        )
    }
    
    func refreshRemote( completion:(([AnyObject]?, NSError?)->())? = nil) {
        self.loadNewItems(
            createOperation: {
                return NotificationsOperation()
            },
            completion: completion
        )
    }
    
    // MARK: - UITableViewDataSource
    
    func registerCells( tableView: UITableView ) {
        let identifier = "VNotificationCell"
        let nib = UINib(nibName: identifier, bundle: NSBundle(forClass:self.dynamicType) )
        tableView.registerNib( nib, forCellReuseIdentifier: identifier)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleItems.count
    }
    
    func tableView( tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VNotificationCell", forIndexPath: indexPath) as! VNotificationCell
        decorate(cell: cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72.0
    }
    
    func decorate(cell notificationCell:VNotificationCell, atIndexPath indexPath: NSIndexPath) {
        let notification = visibleItems[ indexPath.row ] as! VNotification
        notificationCell.notification = notification
        notificationCell.dependencyManager = dependencyManager
        notificationCell.backgroundColor = notification.isRead!.boolValue ? UIColor.whiteColor() : UIColor(red: 0.90, green: 0.91, blue: 0.93, alpha: 1.0)
    }
    
    
}
