//
//  BadgeCountManager.swift
//  victorious
//
//  Created by Jarod Long on 8/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

/// An enum for different types of badge counts that are used in the app.
enum BadgeCountType {
    case unreadNotifications
    
    static let all: [BadgeCountType] = [.unreadNotifications]
}

/// A singleton object that manages global badge counts used across the app.
final class BadgeCountManager {
    
    // MARK: - Initializing
    
    private init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loggedInStatusDidChange), name: kLoggedInChangedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationDidBecomeActive), name: VApplicationDidBecomeActiveNotification, object: nil)
        fetchUnreadNotificationCount()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Accessing the shared instance
    
    static let shared = BadgeCountManager()
    
    // MARK: - Accessing the total badge count
    
    /// The total badge count to be displayed for the app.
    var totalBadgeCount: Int {
        return BadgeCountType.all.reduce(0) { $0 + (badgeCount(for: $1) ?? 0) }
    }
    
    private func updateApplicationBadgeCount() {
        UIApplication.sharedApplication().applicationIconBadgeNumber = totalBadgeCount
    }
    
    // MARK: - Listening for badge count changes
    
    /// Listens for changes in the badge count of the given `type`.
    func whenBadgeCountChanges(for type: BadgeCountType, callback: () -> Void) {
        switch type {
            case .unreadNotifications: whenUnreadNotificationCountChanges.add(callback)
        }
    }
    
    /// A callback that triggers whenever the `unreadNotificationCount` changes.
    private var whenUnreadNotificationCountChanges = Callback<Void>()
    
    // MARK: - Managing badge counts
    
    /// Returns the badge count for the given `type`, or nil if that count hasn't been fetched yet.
    func badgeCount(for type: BadgeCountType) -> Int? {
        switch type {
            case .unreadNotifications: return unreadNotificationCount
        }
    }
    
    /// Fetches the badge count of the given `type`. A callback for the type will be triggered if the count changes.
    func fetchBadgeCount(for type: BadgeCountType) {
        switch type {
            case .unreadNotifications: fetchUnreadNotificationCount()
        }
    }
    
    /// Resets the badge count of the given `type` to zero. A callback for the type will be triggered if the count
    /// changes.
    func resetBadgeCount(for type: BadgeCountType) {
        switch type {
            case .unreadNotifications: markAllNotificationsAsRead()
        }
    }
    
    // MARK: - Managing unread notification count
    
    /// The total number of unread notifications that the user has, or nil if we haven't fetched the count yet.
    private var unreadNotificationCount: Int? {
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
                self?.unreadNotificationCount = count + 3
            }
        }
    }
    
    /// Marks all of the user's notifications as read, resetting the `unreadNotificationCount` to zero.
    private func markAllNotificationsAsRead() {
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
