//
//  InAppNotificationsViewController.swift
//  victorious
//
//  Created by Jarod Long on 8/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

class InAppNotificationsViewController: UIViewController, UITableViewDelegate, InAppNotificationCellDelegate, VBackgroundContainer {
    private struct Constants {
        static let contentInset = UIEdgeInsets(top: 8.0, left: 0.0, bottom: 8.0, right: 0.0)
        static let estimatedRowHeight = CGFloat(64.0)
    }
    
    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        dataSource = InAppNotificationsDataSource(dependencyManager: dependencyManager)
        noContentView = VNoContentView(fromNibWithFrame: tableView.bounds)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = true
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = false
        
        dataSource.registerCells(for: tableView)
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.tintColor = dependencyManager.refreshControlColor
        
        noContentView.setDependencyManager(dependencyManager)
        noContentView.title = NSLocalizedString("NoNotificationsTitle", comment: "")
        noContentView.message = NSLocalizedString("NoNotificationsMessage", comment: "")
        noContentView.icon = UIImage(named: "noNotificationsIcon")
        
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.backgroundColor = nil
        tableView.separatorStyle = .none
        tableView.separatorColor = .clear
        tableView.contentInset = Constants.contentInset
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = Constants.estimatedRowHeight
        tableView.addSubview(refreshControl)
        
        view.addSubview(tableView)
        view.v_addFitToParentConstraints(toSubview: tableView)
        
        
        dependencyManager.addBackground(toBackgroundHost: self)
        dependencyManager.configureNavigationItem(navigationItem)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dependencyManager.trackViewWillAppear(for: self)
        refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        VTrackingManager.sharedInstance().startEvent("Notifications")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dependencyManager.trackViewWillDisappear(for: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        VTrackingManager.sharedInstance().endEvent("Notifications")
    }
    
    // MARK: - Dependency manager
    
    let dependencyManager: VDependencyManager
    
    // MARK: - Data source
    
    private let dataSource: InAppNotificationsDataSource
    
    // MARK: - Views
    
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let noContentView: VNoContentView
    
    private func updateTableView() {
        tableView.separatorStyle = dataSource.visibleItems.count > 0 ? .singleLine : .none
        
        if dataSource.visibleItems.isEmpty {
            tableView.backgroundView = noContentView
        }
        else {
            tableView.backgroundView = nil
        }
    }
    
    // MARK: - Loading content
    
    private dynamic func refresh() {
        refreshControl.beginRefreshing()
        
        dataSource.load() { [weak self] result in
            self?.tableView.reloadData()
            
            self?.refreshControl.endRefreshing()
            self?.updateTableView()
            self?.redecorateVisibleCells()
            
            if result.error == nil {
                BadgeCountManager.shared.resetBadgeCount(for: .unreadNotifications)
            }
        }
    }
    
    private func redecorateVisibleCells() {
        for indexPath in tableView.indexPathsForVisibleRows ?? [] {
            guard let cell = tableView.cellForRow(at: indexPath) as? InAppNotificationCell else {
                continue
            }
            
            dataSource.decorate(cell: cell, atIndexPath: indexPath)
        }
    }
    
    // MARK: - Deep links
    
    private func showDeepLink(_ deepLink: String) {
        guard let url = URL(string: deepLink) else {
            return
        }
        
        let destination = DeeplinkDestination(url: url)
        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        router.navigate(to: destination, from: nil)
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let deepLink = (dataSource.visibleItems[indexPath.row]).deeplink, !deepLink.isEmpty else {
            return
        }
        
        VTrackingManager.sharedInstance().trackEvent(NSNotification.Name.VTrackingEventUserDidSelect.rawValue)
        showDeepLink(deepLink)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? InAppNotificationCell)?.delegate = self
    }
    
    // MARK: - VCellWithProfileDelegate
    
    func notificationCellDidSelectUser(_ cell: InAppNotificationCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let notification = dataSource.visibleItems[indexPath.row]
        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        router.navigate(to: .profile(userID: notification.user.id), from: nil)
    }
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return view
    }
}

private extension VDependencyManager {
    var refreshControlColor: UIColor? {
        return color(forKey: "color.text")
    }
}
