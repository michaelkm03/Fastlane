//
//  ImageBackground.swift
//  victorious
//
//  Created by Vincent Ho on 9/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ImageBackground: VBackground {
    private let backgroundImage: UIImage?
    private static let BackgroundImageKey = "image"
    
    required init(dependencyManager: VDependencyManager) {
        backgroundImage = dependencyManager.imageForKey(ImageBackground.BackgroundImageKey)
        super.init()
    }
    
    override func viewForBackground() -> UIView {
        return UIImageView(image: backgroundImage)
    }
}
