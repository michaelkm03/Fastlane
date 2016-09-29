//
//  VSystemBlurredImageBackground.swift
//  victorious
//
//  Created by Darvish Kamalia on 5/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class SystemBlurredImageBackground : VBackground {
    fileprivate let backgroundImage: UIImage?
    fileprivate let VSystemBlurredImageBackgroundImageKey = "image"

    required init(dependencyManager: VDependencyManager) {
        backgroundImage = dependencyManager.image(forKey: VSystemBlurredImageBackgroundImageKey)
        super.init()
    }

    override func viewForBackground() -> UIView {
        let backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.contentMode = .ScaleAspectFill
        
        let blurEffect = UIBlurEffect(style: .light)
        
        // Create effect view and add constraints so that it stays on top of the image view even if the image view moves/resizes
        let effectView = UIVisualEffectView(effect: blurEffect)
        backgroundImageView.addSubview(effectView)
        backgroundImageView.v_addFitToParentConstraints(toSubview: effectView)
        
        return backgroundImageView
    }
}

