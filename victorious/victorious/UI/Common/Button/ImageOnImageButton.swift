//
//  ImageOnImageButton.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/30/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A template-styled button that displays an image on top of a background image
@objc(VImageOnImageButton)
class ImageOnImageButton: UIButton, TrackableButton {
    
    var dependencyManager: VDependencyManager! {
        didSet {
            
            var backgroundRenderingMode = UIImageRenderingMode.AlwaysOriginal
            if let backgroundColor: UIColor = templateAppearanceValue(.backgroundColor) {
                //Assume that foreground color will be nil, use tintColor
                //to color the background image
                tintColor = backgroundColor
                backgroundRenderingMode = .AlwaysTemplate
            }
            let backgroundImage: UIImage? = templateAppearanceValue(.backgroundImage)
            setBackgroundImage(backgroundImage?.imageWithRenderingMode(backgroundRenderingMode), forState: .Normal)
            
            var foregroundRenderingMode = UIImageRenderingMode.AlwaysOriginal
            if let foregroundColor: UIColor = templateAppearanceValue(.foregroundColor) {
                //Assume that background color was nil, use tintColor
                //to color the foreground image
                tintColor = foregroundColor
                foregroundRenderingMode = .AlwaysTemplate
            }
            let foregroundImage: UIImage? = templateAppearanceValue(.foregroundImage)
            setBackgroundImage(foregroundImage?.imageWithRenderingMode(foregroundRenderingMode), forState: .Normal)
            
            backgroundColor = .clearColor()
        }
    }
}
