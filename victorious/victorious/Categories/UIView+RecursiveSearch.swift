//
//  UIView+RecursiveSearch.swift
//  victorious
//
//  Created by Patrick Lynch on 7/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

extension UIView {
    
    /// Recursively finds the any subviews that return true when used as the parameter to the `pattern` closure
    ///
    /// - parameter pattern: Closure to call to determine if view is the one sought
    /// - returns: A view that passes the test or nil
    func v_findSubviews( _ pattern: (UIView) -> (Bool) ) -> [UIView] {
        var output = [UIView]()
        for subview in self.subviews {
            if pattern( subview ) {
                output.append( subview )
            }
            else {
                output += subview.v_findSubviews( pattern )
            }
        }
        return output
    }
}
