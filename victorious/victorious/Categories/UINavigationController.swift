//
//  UINavigationController.swift
//  victorious
//
//  Created by Tian Lan on 8/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

extension UINavigationController {
    func pushViewController(viewController: UIViewController, animated: Bool, completion: () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
}
