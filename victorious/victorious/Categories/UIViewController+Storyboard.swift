//
//  UIViewController+Storyboard.swift
//  victorious
//
//  Created by Michael Sena on 8/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension UIViewController {
    
    /// Instantiates a UIViewController within the appropriate bundle. Using a storyboard that is named exactly 
    /// like the class name, with an identifier named exactly like the class name.
    static func v_fromStoryboard<T: UIViewController>( _ storyboardName: String? = nil, identifier: String? = nil) -> T {
        let storyboard = UIStoryboard(name: storyboardName ?? String(self), bundle: nil )
        return storyboard.instantiateViewControllerWithIdentifier( identifier ?? String(self) ) as! T
    }
    
    /// Instantiates a UIViewController within the appropriate bundle. Using a storyboard that is named exactly
    /// like the class name, with the initialViewController of the storyboard.
    static func v_initialViewControllerFromStoryboard<T: UIViewController>( _ storyboardName: String? = nil ) -> T {
        let storyboard = UIStoryboard(name: storyboardName ?? String(self), bundle: nil )
        return storyboard.instantiateInitialViewController() as! T
    }
}
