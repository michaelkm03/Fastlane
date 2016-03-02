//
//  LightboxControllerDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol LightboxControllerDelegate: class {
    
    func lightboxPressedDismiss(lightbox: LightboxController)
    
    func lightbox(lightbox: LightboxController, selectedOverflowMenuItem: LightboxControllerOverflowMenuItem)
}
