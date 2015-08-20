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
    static func v_fromStoryboardWithIdentifier<T: UIViewController>() -> T {
        let bundleForClass = NSBundle(forClass: self)
        let storyboard = UIStoryboard(name: NSStringFromClass(self).pathExtension, bundle: nil )
        return storyboard.instantiateViewControllerWithIdentifier( NSStringFromClass(self).pathExtension ) as! T
    }
    
    /// Instantiates a UIViewController within the appropriate bundle. Using a storyboard that is named exactly
    /// like the class name, with the initialViewController of the storyboard.
    static func v_fromStoryboardInitialViewController<T: UIViewController>() -> T {
        let bundleForClass = NSBundle(forClass: self)
        let storyboard = UIStoryboard(name: NSStringFromClass(self).pathExtension, bundle: nil )
        return storyboard.instantiateInitialViewController() as! T
    }
    
}
