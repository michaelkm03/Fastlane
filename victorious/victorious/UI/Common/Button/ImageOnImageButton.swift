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
            var backgroundImage: UIImage? = templateAppearanceValue(appearance: .backgroundImage)
            if let backgroundColor: UIColor = templateAppearanceValue(appearance: .backgroundColor) {
                backgroundImage = backgroundImage?.v_tintedTemplateImage(with: backgroundColor)
            }
            setBackgroundImage(backgroundImage?.withRenderingMode(.alwaysOriginal), for: .normal)
            
            var foregroundImage: UIImage? = templateAppearanceValue(appearance: .foregroundImage)
            if let foregroundColor: UIColor = templateAppearanceValue(appearance: .foregroundColor) {
                foregroundImage = foregroundImage?.v_tintedTemplateImage(with: foregroundColor)
            }
            setImage(foregroundImage?.withRenderingMode(.alwaysOriginal), for: .normal)
            
            backgroundColor = .clear
            isUserInteractionEnabled = templateAppearanceValue(appearance: .clickable) ?? false
        }
    }
}
