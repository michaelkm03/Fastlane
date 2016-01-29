//
//  VDiscoverContainerViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 1/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VDiscoverContainerViewController {
    
    // MARK: - SearchResultsViewControllerDelegate
    
    func searchResultsViewControllerDidSelectCancel() { }
    
    func searchResultsViewControllerDidSelectResult(result: AnyObject) {
        
        guard let navController = self.navigationController,
            let dependencyManager = self.dependencyManager else {
                return
        }
        
        let operation = ShowSearchResultOperation(
            searchResult: result,
            onNavigationController: navController,
            dependencyManager: dependencyManager
        )
        operation.queue()
    }
}
