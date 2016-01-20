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
    
    func decorateActivityCell( activityCell: ActivityFooterTableCell ) {
        
        let shouldShowLoadingAnimation = self.isLoading() && visibleItems.count > 0
        activityCell.loading = shouldShowLoadingAnimation
        
        // Move separators way out of the way, effective hiding them for just this cell
        activityCell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 10000)
    }
    
    // MARK: - UITableViewDataSource
    
    func registerCells( tableView: UITableView ) {
        let identifier = "VNotificationCell"
        let nib = UINib(nibName: identifier, bundle: NSBundle(forClass:self.dynamicType) )
        tableView.registerNib( nib, forCellReuseIdentifier: identifier)
        
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
    
    func tableView( tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath ) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("VNotificationCell", forIndexPath: indexPath) as! VNotificationCell
            cell.notification = visibleItems[ indexPath.row ] as! VNotification
            cell.dependencyManager = self.dependencyManager
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
}
