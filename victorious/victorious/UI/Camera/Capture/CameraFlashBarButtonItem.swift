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
    
    fileprivate(set) var interactiveButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isHidden = true
        button.isEnabled = false
        button.frame = button.v_navigationBarFriendlyFrame
        button.setBackgroundImage(nil, for: .selected)
        button.imageView?.contentMode = .center
        button.setTitle(nil, for: UIControlState())
        button.setTitle(nil, for: .selected)
        return button
    }()

    var dependencyManager: VDependencyManager? {
        didSet {
            interactiveButton.setImage(dependencyManager?.normalStateImage, for: .normal)
            interactiveButton.setImage(dependencyManager?.selectedStateImage, for: .selected)
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
    
    fileprivate func setup() {
        customView = interactiveButton
        title = nil
        setBackButtonBackgroundImage(nil, for: UIControlState(), barMetrics: .default)
        setBackButtonBackgroundImage(nil, for: .selected, barMetrics: .default)
    }
}

private extension VDependencyManager {
    
    var normalStateImage: UIImage? {
        return image(forKey: "disableFlashIcon")
    }
    
    var selectedStateImage: UIImage? {
        return image(forKey: "flashIcon")
    }
}
