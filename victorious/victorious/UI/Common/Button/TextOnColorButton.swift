//
//  TextOnColorButton.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/30/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A template-styled button that displays text on top of a solid-color background
@objc(VTextOnColorButton)
class TextOnColorButton: UIButton, TrackableButton {
    
    var dependencyManager: VDependencyManager! {
        didSet {
            
            backgroundColor = templateAppearanceValue(.backgroundColor)
            setTitleColor(templateAppearanceValue(.foregroundColor), forState: .Normal)
            setTitle(templateAppearanceValue(.text), forState: .Normal)
        }
    }
}
