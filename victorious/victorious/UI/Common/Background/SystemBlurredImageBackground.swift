//
//  VSystemBlurredImageBackground.swift
//  victorious
//
//  Created by Darvish Kamalia on 5/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class SystemBlurredImageBackground : VBackground {
    private let backgroundImage: UIImage?
    private let VSystemBlurredImageBackgroundImageKey = "image"

    required init(dependencyManager: VDependencyManager) {
        backgroundImage = dependencyManager.imageForKey(VSystemBlurredImageBackgroundImageKey)
        super.init()
    }

    override func viewForBackground() -> UIView {
        let backgroundImageView = UIImageView(image: backgroundImage)
        let blurEffect = UIBlurEffect(style: .Light)
        
        // Create effect view and add constraints so that it stays on top of the image view even if the image view moves/resizes
        let effectView = UIVisualEffectView(effect: blurEffect)
        backgroundImageView.addSubview(effectView)
        backgroundImageView.v_addFitToParentConstraintsToSubview(effectView)
        
        return backgroundImageView
    }
}

