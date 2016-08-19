//
//  VRootViewController.swift
//  victorious
//
//  Created by Tian Lan on 6/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VRootViewController {
    
    // MARK: - Bridging with Obj-C
    
    func showDeeplink(deeplink: NSURL, on scaffold: UIViewController) {
        // Ideally we would pass in a `Scaffold` type to avoid this check, but this function is being called by
        // dear Obj-C so that was not an option.
        if let scaffold = scaffold as? Scaffold {
            scaffold.navigate(to: deeplink)
        }
    }
    
    func showLogin() {
        guard let scaffoldDependencyManager = dependencyManager.scaffoldDependencyManager else {
            return
        }
        ShowLoginOperation(originViewController: self, dependencyManager: scaffoldDependencyManager, context: .Default, animated: false).queue { [weak self] result in
            switch result {
                case .success: self?.initializeScaffold()
                case .failure: self?.v_showErrorDefaultError()
                case .cancelled: break
            }
        }
    }
}

private extension VDependencyManager {
    var scaffoldDependencyManager: VDependencyManager? {
        return childDependencyForKey(VDependencyManagerScaffoldViewControllerKey)
    }
}
