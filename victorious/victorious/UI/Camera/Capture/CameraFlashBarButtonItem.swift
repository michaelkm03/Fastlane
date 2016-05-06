//
//  CameraFlashBarButtonItem.swift
//  victorious
//
//  Created by Sharif Ahmed on 4/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

@objc(VCameraFlashBarButtonItem)
class CameraFlashBarButtonItem: UIBarButtonItem {
    
    private(set) var interactiveButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.hidden = true
        button.enabled = false
        button.frame = button.v_navigationBarFriendlyFrame
        button.setBackgroundImage(nil, forState: .Selected)
        button.imageView?.contentMode = .Center
        button.setTitle(nil, forState: .Normal)
        button.setTitle(nil, forState: .Selected)
        return button
    }()

    var dependencyManager: VDependencyManager? {
        didSet {
            interactiveButton.setImage(dependencyManager?.normalStateImage, forState: .Normal)
            interactiveButton.setImage(dependencyManager?.selectedStateImage, forState: .Selected)
        }
    }
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        customView = interactiveButton
        title = nil
        setBackButtonBackgroundImage(nil, forState: .Normal, barMetrics: .Default)
        setBackButtonBackgroundImage(nil, forState: .Selected, barMetrics: .Default)
    }
}

private extension VDependencyManager {
    
    var normalStateImage: UIImage? {
        return imageForKey("disableFlashIcon")
    }
    
    var selectedStateImage: UIImage? {
        return imageForKey("flashIcon")
    }
}
