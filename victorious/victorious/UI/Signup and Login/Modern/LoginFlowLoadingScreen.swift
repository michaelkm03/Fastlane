//
//  LoginFlowLoadingScreen.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 10/22/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

@objc protocol LoginFlowLoadingScreen {
    
    /// A block that should get called when the loading screen finishes appearing. 
    /// Adopters of this protocol should nullify this block after it's called.
    var onAppearance: (() -> ())? { get set }
    
    /// Whether or not the loading screen can be cancelled.
    var canCancel: Bool { get set }
}
