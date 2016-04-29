//
//  UIViewController+RootNavigationController.swift
//  victorious
//
//  Created by Jarod Long on 4/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension UIViewController {
    var rootNavigationController: VNavigationController? {
        return (self as? Scaffold)?.mainNavigationController ?? parentViewController?.rootNavigationController
    }
}
