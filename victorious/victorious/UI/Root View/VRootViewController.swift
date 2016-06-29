//
//  VRootViewController.swift
//  victorious
//
//  Created by Tian Lan on 6/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VRootViewController {
    
    // MARK: - Bridging with Objc-C
    
    func showDeeplink(deeplink: NSURL, on scaffold: UIViewController) {
        // Ideally we would pass in a `Scaffold` type to avoid this check, but this function is being called by
        // dear Objc-C so that was not an option.
        if let scaffold = scaffold as? Scaffold {
            scaffold.navigate(to: deeplink)
        }
    }
}
