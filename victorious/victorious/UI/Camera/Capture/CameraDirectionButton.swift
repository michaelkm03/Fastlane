//
//  CameraDirectionButton.swift
//  victorious
//
//  Created by Sharif Ahmed on 4/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

@objc(VCameraDirectionButton)
class CameraDirectionButton: UIButton {
    
    var dependencyManager: VDependencyManager? {
        didSet {
            setImage(dependencyManager?.buttonImage, forState: .Normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        hidden = true
        enabled = false
        frame = v_navigationBarFriendlyFrame
        setBackgroundImage(nil, forState: .Selected)
        imageView?.contentMode = .Center
        setTitle(nil, forState: .Normal)
    }
}

private extension VDependencyManager {
    
    var buttonImage: UIImage {
        return imageForKey("reverseCameraIcon")
    }
}
