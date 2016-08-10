//
//  ImageOnColorButton.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/30/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A template-styled button that displays an image on top of a solid-color background
@objc(VImageOnColorButton)
class ImageOnColorButton: TouchableInsetAdjustableButton, TrackableButton {
    var dependencyManager: VDependencyManager? {
        didSet {
            backgroundColor = templateAppearanceValue(.backgroundColor)
            
            var foregroundRenderingMode = UIImageRenderingMode.AlwaysOriginal
            if let foregroundColor: UIColor = templateAppearanceValue(.foregroundColor) {
                //Assume that background color was nil, use tintColor
                //to color the foreground image
                tintColor = foregroundColor
                foregroundRenderingMode = .AlwaysTemplate
            }
            let foregroundImage: UIImage? = templateAppearanceValue(.foregroundImage)
            setImage(foregroundImage?.imageWithRenderingMode(foregroundRenderingMode), forState: .Normal)
            
            self.enabled = templateAppearanceValue(.clickable) ?? false
        }
    }
}
