//
//  CrossFadingNavigationControllerDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class CrossFadingNavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    var animationController: CrossFadingAnimationController
    
    var fadingEnabled = true
    
    init(animationController: CrossFadingAnimationController = CrossFadingAnimationController()) {
        self.animationController = animationController
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return fadingEnabled ? animationController : nil
    }
}
