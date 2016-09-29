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
            setImage(dependencyManager?.buttonImage, for: .Normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        isHidden = true
        isEnabled = false
        frame = v_navigationBarFriendlyFrame
        setBackgroundImage(nil, for: .selected)
        imageView?.contentMode = .center
        setTitle(nil, for: UIControlState())
    }
}

private extension VDependencyManager {
    
    var buttonImage: UIImage {
        return image(forKey: "reverseCameraIcon")
    }
}
