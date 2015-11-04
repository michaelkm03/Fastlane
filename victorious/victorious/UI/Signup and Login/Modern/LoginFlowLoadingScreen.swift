//
//  LoginFlowLoadingScreen.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 10/22/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

@objc protocol LoginFlowLoadingScreen {
    
    /// The loading screen's delegate
    weak var loadingScreenDelegate: LoginLoadingScreenDelegate? { get set }
    
    /// Whether or not the loading screen can be cancelled.
    var canCancel: Bool { get set }
}

@objc protocol LoginLoadingScreenDelegate {
    
    /// Called when the login screen appears for the first time
    func loadingScreenDidAppear()
    
    /// Called when the user presses the cancel button
    func loadingScreenCancelled()
}
