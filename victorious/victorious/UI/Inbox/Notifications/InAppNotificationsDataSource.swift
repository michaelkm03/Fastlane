//
//  InAppNotificationsDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class InAppNotificationsDataSource: PaginatedDataSource, UITableViewDataSource {
    let dependencyManager: VDependencyManager
    
    required init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
    }
    
    func loadNotifications(_ pageType: VPageType, completion: ((NSError?) -> ())? = nil ) {
        loadPage( pageType,
            createOperation: { NotificationsOperation() },
            completion: { (results, error, cancelled) in
                completion?(error)
            }
        )
    }
    
    // MARK: - UITableViewDataSource
    
    func registerCells(for tableView: UITableView) {
        let identifier = "NotificationCell"
        let nib = UINib(nibName: identifier, bundle: Bundle(for:type(of: self)) )
        tableView.register(nib, forCellReuseIdentifier: identifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath as IndexPath) as! InAppNotificationCell
        decorate(cell: cell, atIndexPath: indexPath as IndexPath)
        return cell
    }
    
    func decorate(cell notificationCell: InAppNotificationCell, atIndexPath indexPath: IndexPath) {
        let notification = visibleItems[indexPath.row] as! Notification
        notificationCell.updateContent(with: notification, dependencyManager: dependencyManager)
    }
}
