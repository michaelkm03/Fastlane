//
//  NavigationBarHiddenTabViewController.swift
//  victorious
//
//  Created by Michael Sena on 8/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class NavigationBarHiddenTabViewController: UITabBarController {
    
    override func v_prefersNavigationBarHidden() -> Bool {
        return true
    }
    
}
