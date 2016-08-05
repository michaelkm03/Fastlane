//
//  ScrollPaginator.swift
//  victorious
//
//  Created by Jarod Long on 7/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// A reusable helper struct that encapsulates the logic for performing pagination in a vertical scroll view.
///
/// To use it, you just need to listen for the callbacks that you're interested in and call the `scrollViewDidScroll`
/// method appropriately.
///
struct ScrollPaginator {
    /// Initializes with the loading callbacks.
    init(loadItemsAbove: (() -> Void)? = nil, loadItemsBelow: (() -> Void)? = nil) {
        self.loadItemsAbove = loadItemsAbove
        self.loadItemsBelow = loadItemsBelow
    }
    
    /// A configurable value that determines how close to the top or bottom the scroll view must be to trigger loading
    /// of new content.
    var tolerance = CGFloat(5.0)
    
    /// A callback that occurs when items at the top of the scroll view are requested.
    var loadItemsAbove: (() -> Void)?
    
    /// A callback that occurs when items at the bottom of the scroll view are requested.
    var loadItemsBelow: (() -> Void)?
    
    /// The owner of the paginator must call this in the `scrollViewDidScroll` delegate method of the associated scroll
    /// view.
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.isScrolledToTop(withTolerance: tolerance) {
            loadItemsAbove?()
        }
        
        if scrollView.isScrolledToBottom(withTolerance: tolerance) {
            loadItemsBelow?()
        }
    }
}
