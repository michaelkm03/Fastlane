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
            backgroundColor = templateAppearanceValue(appearance: .backgroundColor)
            
            var foregroundRenderingMode = UIImageRenderingMode.alwaysOriginal
            if let foregroundColor: UIColor = templateAppearanceValue(appearance: .foregroundColor) {
                //Assume that background color was nil, use tintColor
                //to color the foreground image
                tintColor = foregroundColor
                foregroundRenderingMode = .alwaysTemplate
            }
            let foregroundImage: UIImage? = templateAppearanceValue(appearance: .foregroundImage)
            setImage(foregroundImage?.withRenderingMode(foregroundRenderingMode), for: .normal)
            
            isUserInteractionEnabled = templateAppearanceValue(appearance: .clickable) ?? false
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return imageView?.intrinsicContentSize ?? super.intrinsicContentSize
    }
}
