//
//  TextOnImageButton.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/30/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A template-styled button that displays text on top of a background image
@objc(VTextOnImageButton)
class TextOnImageButton: TouchableInsetAdjustableButton, TrackableButton {
    var dependencyManager: VDependencyManager? {
        didSet {
            var backgroundRenderingMode = UIImageRenderingMode.alwaysOriginal
            if let backgroundColor: UIColor = templateAppearanceValue(appearance: .backgroundColor) {
                tintColor = backgroundColor
                backgroundRenderingMode = .alwaysTemplate
            }
            let backgroundImage: UIImage? = templateAppearanceValue(appearance: .backgroundImage)
            setBackgroundImage(backgroundImage?.withRenderingMode(backgroundRenderingMode), for: .normal)
            
            setTitleColor(templateAppearanceValue(appearance: .foregroundColor), for: .normal)
            setTitle(templateAppearanceValue(appearance: .text), for: .normal)
            titleLabel?.font = templateAppearanceValue(appearance: .font)
            
            backgroundColor = .clear
            isUserInteractionEnabled = templateAppearanceValue(appearance: .clickable) ?? false
        }
    }
}
