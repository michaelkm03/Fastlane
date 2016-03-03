//
//  LightboxViewControllerDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol LightboxViewControllerDelegate: class {
    
    /// Called when the dismiss button is pressed on the lightboxController
    func lightboxPressedDismiss(lightbox: LightboxViewController)
    
    /// Called when an overflow menu item is selected from the lightbox's overflow menu
    func lightbox(lightbox: LightboxViewController, selectedOverflowMenuItem: LightboxViewControllerOverflowMenuItem)
}
