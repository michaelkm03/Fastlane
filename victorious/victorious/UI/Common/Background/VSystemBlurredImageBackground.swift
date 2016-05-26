//
//  VSystemBlurredImageBackground.swift
//  victorious
//
//  Created by Darvish Kamalia on 5/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class VSystemBlurredImageBackground : VBackground {

    private let backgroundImage: UIImage
    private let dependencyManager: VDependencyManager
    private let VSystemBlurredImageBackgroundImageKey = "image"

    required init (dependencyManager: VDependencyManager) {
        self.backgroundImage = dependencyManager.imageForKey(VSystemBlurredImageBackgroundImageKey)
        self.dependencyManager = dependencyManager
        super.init()
    }

    override func viewForBackground() -> UIView! {
        let backgroundImageView = UIImageView(image: backgroundImage)
        let blurEffect = UIBlurEffect(style: .Light)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = backgroundImageView.frame
        backgroundImageView.addSubview(effectView)
        return backgroundImageView
    }
}
