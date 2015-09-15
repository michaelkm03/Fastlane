//
//  InterstitialConfiguration.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// An abstract interface that interstitial objects can use to configure themselves
/// with their parameters payload and return a custom view controller representing itself
protocol InterstitialConfiguration {
    
    /// Allows the interstitial to configure itself based on it's payload
    func configureWithInfo(info: [String : AnyObject])
    
    /// Returns a view controller that will show in it's own window when the interstitial is registered
    func viewControllerToPresent() -> InterstitialViewController?
}