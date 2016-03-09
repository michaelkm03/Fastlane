//
//  LightboxViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class LightboxViewController: UIViewController, Lightbox {
    
    weak var delegate: LightboxDelegate?
    
    func populateWithMedia(media: VAsset, andOverflowMenuItems menuItems: [LightboxMenuItem]) {
        
    }
}
