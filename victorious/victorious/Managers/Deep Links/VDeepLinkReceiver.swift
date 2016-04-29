//
//  VDeepLinkReceiver.swift
//  victorious
//
//  Created by Jarod Long on 4/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

extension VDeeplinkReceiver {
    // MARK: - Objective-C compatibility
    
    var navigationDestinations: [VNavigationDestination] {
        return (scaffold as? Scaffold)?.navigationDestinations ?? []
    }
    
    func navigate(to destination: UIViewController, animated: Bool) {
        (scaffold as? Scaffold)?.navigate(to: destination, animated: animated)
    }
}
