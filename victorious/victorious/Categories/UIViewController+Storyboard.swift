//
//  UIViewController+Storyboard.swift
//  victorious
//
//  Created by Michael Sena on 8/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension UIViewController {
    
    static func fromStoryboardWithIdentifier<T: UIViewController>() -> T {
        let bundleForClass = NSBundle(forClass: self)
        let storyboard = UIStoryboard(name: NSStringFromClass(self).pathExtension, bundle: nil )
        return storyboard.instantiateViewControllerWithIdentifier( NSStringFromClass(self).pathExtension ) as! T
    }
    
    static func fromStoryboardInitialViewController<T: UIViewController>() -> T {
        let bundleForClass = NSBundle(forClass: self)
        let storyboard = UIStoryboard(name: NSStringFromClass(self).pathExtension, bundle: nil )
        return storyboard.instantiateInitialViewController() as! T
    }
    
}
