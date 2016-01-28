//
//  SearchDataSourceType.swift
//  victorious
//
//  Created by Patrick Lynch on 1/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Defines an object that implements a paginated data source for a UITableView
protocol SearchDataSourceType: class, PaginatedDataSourceType, UITableViewDataSource {
    
    /// Register nibs, classes intended to be used in the table view
    func registerCells( forTableView tableView: UITableView )

    /// Perform a paginated search over the network.
    func search(searchTerm searchTerm: String, pageType: VPageType, completion:((NSError?)->())? )
    
    var searchTerm: String? { get }
    
    var separatorStyle: UITableViewCellSeparatorStyle { get }
}

@objc protocol SearchResultsViewControllerDelegate: class {
    
    /// If the search UI contains a cancel button, respond to its selection
    func searchResultsViewControllerDidSelectCancel()
    
    func searchResultsViewControllerDidSelectResult(result: AnyObject)
}
