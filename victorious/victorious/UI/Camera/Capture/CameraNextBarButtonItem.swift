//
//  CameraNextBarButtonItem.swift
//  victorious
//
//  Created by Sharif Ahmed on 4/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

@objc(VCameraNextBarButtonItem)
class CameraNextBarButtonItem: UIBarButtonItem {
    
    var dependencyManager: VDependencyManager? {
        didSet {
            title = dependencyManager?.nextBarButtonItemText
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        isEnabled = false
    }
}

private extension VDependencyManager {
    
    var nextBarButtonItemText: String {
        return stringForKey("nextText")
    }
}
