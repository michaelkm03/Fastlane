//
//  UIViewController+RootPresentationTarget.swift
//  victorious
//
//  Created by Patrick Lynch on 4/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension UIViewController {
    
    /// Returns the root view controller of the application or the topmost presented
    /// view controller if there are one or more view controllers already presented.
    static func v_rootPresentationTargetViewController() -> UIViewController? {
        var targetViewController = UIApplication.sharedApplication().delegate?.window??.rootViewController
        while let presentedViewController = targetViewController?.presentedViewController {
            targetViewController = presentedViewController
        }
        return targetViewController
    }
}
