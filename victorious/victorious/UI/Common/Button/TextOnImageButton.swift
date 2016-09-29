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
            var backgroundRenderingMode = UIImageRenderingMode.AlwaysOriginal
            if let backgroundColor: UIColor = templateAppearanceValue(.backgroundColor) {
                tintColor = backgroundColor
                backgroundRenderingMode = .AlwaysTemplate
            }
            let backgroundImage: UIImage? = templateAppearanceValue(.backgroundImage)
            setBackgroundImage(backgroundImage?.imageWithRenderingMode(backgroundRenderingMode), forState: .Normal)
            
            setTitleColor(templateAppearanceValue(.foregroundColor), forState: .Normal)
            setTitle(templateAppearanceValue(.text), forState: .Normal)
            titleLabel?.font = templateAppearanceValue(.font)
            
            backgroundColor = .clear
            userInteractionEnabled = templateAppearanceValue(.clickable) ?? false
        }
    }
}
