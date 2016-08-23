//
//  BadgeCountManager.swift
//  victorious
//
//  Created by Jarod Long on 8/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

/// A singleton object that manages global badge counts used across the app.
final class BadgeCountManager {
    
    // MARK: - Initializing
    
    private init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loggedInStatusDidChange), name: kLoggedInChangedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationDidBecomeActive), name: VApplicationDidBecomeActiveNotification, object: nil)
        fetchUnreadNotificationCount()
    }
    
    // MARK: - Accessing the shared instance
    
    static let shared = BadgeCountManager()
    
    // MARK: - Accessing the total badge count
    
    /// The total badge count to be displayed for the app.
    var totalBadgeCount: Int {
        // Just notifications for now, but we should add other counts once we have them.
        return unreadNotificationCount ?? 0
    }
    
    private func updateApplicationBadgeCount() {
        UIApplication.sharedApplication().applicationIconBadgeNumber = totalBadgeCount
    }
    
    // MARK: - Listening for badge count changes
    
    /// A callback that triggers whenever the `unreadNotificationCount` changes.
    var whenUnreadNotificationCountChanges = Callback<Void>()
    
    // MARK: - Managing the unread notification count
    
    /// The total number of unread notifications that the user has, or nil if we haven't fetched the count yet.
    private(set) var unreadNotificationCount: Int? {
        didSet {
            guard unreadNotificationCount != oldValue else {
                return
            }
            
            updateApplicationBadgeCount()
            whenUnreadNotificationCountChanges.call()
        }
    }
    
    /// Retrieves the user's current unread notification count and updates `unreadNotificationCount` accordingly.
    private func fetchUnreadNotificationCount() {
        let operation = NotificationsUnreadCountOperation()
        
        operation.queue { [weak self, weak operation] results, error, cancelled in
            if let count = operation?.unreadNotificationsCount?.integerValue where error == nil {
                self?.unreadNotificationCount = count
            }
        }
    }
    
    /// Marks all of the user's notifications as read, resetting the `unreadNotificationCount` to zero.
    func markAllNotificationsAsRead() {
        let previousCount = unreadNotificationCount
        
        // Optimistically reset to zero.
        unreadNotificationCount = 0
        
        NotificationsMarkAllAsReadOperation().queue { [weak self] results, error, cancelled in
            // Reset back to the old count if the request failed.
            if error != nil {
                self?.unreadNotificationCount = previousCount
            }
        }
    }
    
    // MARK: - Notifications
    
    private dynamic func applicationDidBecomeActive(notification: NSNotification?) {
        if VCurrentUser.user() != nil {
            fetchUnreadNotificationCount()
        }
    }
    
    private dynamic func loggedInStatusDidChange(notification: NSNotification?) {
        if VCurrentUser.user() != nil {
            fetchUnreadNotificationCount()
        }
        else {
            unreadNotificationCount = 0
        }
    }
}
