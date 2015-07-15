//
//  GIFSearchViewController+Scrolling.swift
//  victorious
//
//  Created by Patrick Lynch on 7/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

extension GIFSearchViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.scrollPaginator.scrollViewDidScroll( scrollView )
        if self.searchBar.isFirstResponder() {
            self.searchBar.resignFirstResponder()
        }
    }
}

extension GIFSearchViewController : VScrollPaginatorDelegate {
    
    func shouldLoadNextPage() {
        if let searchText = self.searchBar.text {
            self.performSearch(searchText, pageType: .Next)
        }
    }
}