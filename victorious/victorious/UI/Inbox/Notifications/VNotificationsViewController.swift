//
//  VNotificationsViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 2/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VNotificationsViewController {
    
    func updateTableView() {
        
        self.tableView.separatorStyle = self.dataSource.visibleItems.count > 0 ? .SingleLine : .None
        let isAlreadyShowingNoContent = tableView.backgroundView == self.noContentView
        
        switch self.dataSource.state {
            
        case .NoResults, .Loading where isAlreadyShowingNoContent:
            guard let tableView = self.tableView else {
                break
            }
            if !isAlreadyShowingNoContent {
                self.noContentView.resetInitialAnimationState()
                self.noContentView.animateTransitionIn()
            }
            tableView.backgroundView = self.noContentView
            
        default:
            self.tableView.backgroundView = nil
        }
    }
    
    func showDeeplink(with urlString: String?) {
        guard
            let urlString = urlString,
            let url = NSURL(string: urlString)
        else {
            return
        }
        
        let destination = DeeplinkDestination(url: url)
        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        router.navigate(to: destination)
    }
}
