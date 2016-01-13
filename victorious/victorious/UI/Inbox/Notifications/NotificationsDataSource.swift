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
    
    // MARK: - UITableViewDataSource
    
    func registerCells( tableView: UITableView ) {
        let identifier = "VNotificationCell"
        let nib = UINib(nibName: identifier, bundle: NSBundle(forClass:self.dynamicType) )
        tableView.registerNib( nib, forCellReuseIdentifier: identifier)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VNotificationCell", forIndexPath: indexPath) as! VNotificationCell
        cell.notification = visibleItems[ indexPath.row ] as! VNotification
        cell.dependencyManager = self.dependencyManager
        return cell
    }
}
