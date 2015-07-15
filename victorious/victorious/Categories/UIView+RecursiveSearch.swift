//
//  UIView+RecursiveSearch.swift
//  victorious
//
//  Created by Patrick Lynch on 7/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

extension UIView {
    
    /// Recursively finds a view that when provided the the `pattern` closure, returns true
    ///
    /// :parameter: `pattern`: Closure to call to determine if view is the one sought
    /// :returns: A view that passes the test or nil
    func v_findSubview( pattern: (UIView)->(Bool) ) -> UIView? {
        for subview in self.subviews as! [UIView] {
            if pattern( subview ) {
                return subview
            }
            else if let result = subview.v_findSubview( pattern ) {
                return result
            }
        }
        return nil
    }
}