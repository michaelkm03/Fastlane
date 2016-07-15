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
    
    init(animationController: CrossFadingAnimationController = CrossFadingAnimationController()) {
        self.animationController = animationController
    }
    
    func navigationController(
        navigationController: UINavigationController,
        animationControllerForOperation operation: UINavigationControllerOperation,
        fromViewController fromVC: UIViewController,
        toViewController toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return animationController
    }
}
