//
//  VUserTaggingTextStorage.swift
//  victorious
//
//  Created by Michael Sena on 1/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VUserTaggingTextStorage {
    
    func searchWithTerm(searchTerm: String, onSearchResultsViewController searchResultsViewController: SearchResultsViewController) {
        let dataSource = UserSearchDataSource()
        searchResultsViewController.dataSource = dataSource
        dataSource.search(searchTerm: searchTerm, pageType: .First)
    }
    
}
