//
//  InterstitialViewController.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// View controllers that wish to be presented as interstitials should conform to this protocol
protocol InterstitialViewController: class {
    
    /// A delegate to be informed of interstitial events
    weak var interstitialDelegate: InterstitialViewControllerControl? { get set }
    
    /// The time interval with which the manager will cross dissolve this view controller into the window
    func presentationDuration() -> Double
}

protocol InterstitialViewControllerControl: class {
    
    /// Informs the delegate that the user wants to dismiss the interstitial
    func dismissInterstitial()
}
