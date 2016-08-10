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
class ImageOnImageButton: TouchableInsetAdjustableButton, TrackableButton {
    var dependencyManager: VDependencyManager? {
        didSet {
            var backgroundImage: UIImage? = templateAppearanceValue(.backgroundImage)
            if let backgroundColor: UIColor = templateAppearanceValue(.backgroundColor) {
                backgroundImage = backgroundImage?.v_tintedTemplateImageWithColor(backgroundColor)
            }
            setBackgroundImage(backgroundImage?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
            
            var foregroundImage: UIImage? = templateAppearanceValue(.foregroundImage)
            if let foregroundColor: UIColor = templateAppearanceValue(.foregroundColor) {
                foregroundImage = foregroundImage?.v_tintedTemplateImageWithColor(foregroundColor)
            }
            setImage(foregroundImage?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
            
            backgroundColor = .clearColor()
            self.enabled = templateAppearanceValue(.clickable) ?? false
        }
    }
}
