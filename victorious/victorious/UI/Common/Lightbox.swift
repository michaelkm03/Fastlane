//
//  Lightbox.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol Lightbox {
    
    weak var delegate: LightboxDelegate? { get set }
    
    func populateWithMedia(media: VAsset, andOverflowMenuItems menuItems: [LightboxMenuItem])
}