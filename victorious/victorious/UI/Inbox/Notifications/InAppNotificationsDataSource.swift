//
//  InAppNotificationsDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

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
        let nib = UINib(nibName: InAppNotificationCell.defaultReuseIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: InAppNotificationCell.defaultReuseIdentifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InAppNotificationCell.defaultReuseIdentifier, for: indexPath) as! InAppNotificationCell
        decorate(cell: cell, atIndexPath: indexPath)
        return cell
    }
    
    func decorate(cell notificationCell: InAppNotificationCell, atIndexPath indexPath: IndexPath) {
        let notification = visibleItems[indexPath.row] as! InAppNotification
        notificationCell.updateContent(with: notification, dependencyManager: dependencyManager)
    }
}
