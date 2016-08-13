//
//  UINavigationController.swift
//  victorious
//
//  Created by Tian Lan on 8/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

// MARK: - Completion Block

extension UINavigationController {
    func pushViewController(viewController: UIViewController, animated: Bool, completion: Void -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
}
