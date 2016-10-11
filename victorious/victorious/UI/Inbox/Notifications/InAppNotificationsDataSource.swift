//
//  InAppNotificationsDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class InAppNotificationsDataSource: NSObject, UITableViewDataSource {
    let dependencyManager: VDependencyManager
    
    private(set) var visibleItems: [InAppNotification] = []
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        super.init()
    }
    
    func loadNotifications(_ completion: ((NSError?) -> Void)? = nil ) {
        guard
            let notificationAPIPath = dependencyManager.notificationListApiPath,
            let request = InAppNotificationsRequest(apiPath: notificationAPIPath)
        else {
            Log.warning("")
            return
        }
        RequestOperation(request: request).queue() { result in
            
        }
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
        let notification = visibleItems[indexPath.row]
        notificationCell.updateContent(with: notification, dependencyManager: dependencyManager)
    }
}

private extension VDependencyManager {
    var notificationListApiPath: APIPath? {
        return apiPath(forKey: "notification.list.URL")
    }
}
