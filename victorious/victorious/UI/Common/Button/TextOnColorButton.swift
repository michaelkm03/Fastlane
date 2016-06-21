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
    var dependencyManager: VDependencyManager? {
        didSet {
            backgroundColor = templateAppearanceValue(.backgroundColor)
            setTitleColor(templateAppearanceValue(.foregroundColor), forState: .Normal)
            setTitle(templateAppearanceValue(.text), forState: .Normal)
            let font: UIFont = templateAppearanceValue(.font)!
            titleLabel?.font = font
            self.enabled = templateAppearanceValue(.clickable) ?? false
        }
    }
    
    override var highlighted: Bool {
        didSet {
            alpha = highlighted ? 0.5 : 1.0
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.v_roundCornerRadius
    }
}
