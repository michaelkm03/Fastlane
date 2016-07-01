//
//  TextOnColorButton.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/30/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

enum TextOnColorButtonRoundingType {
    case pill
    case roundedRect(radius: CGFloat)
}

/// A template-styled button that displays text on top of a solid-color background
@objc(VTextOnColorButton)
class TextOnColorButton: UIButton, TrackableButton {
    var dependencyManager: VDependencyManager? {
        didSet {
            hidden = dependencyManager == nil
            backgroundColor = templateAppearanceValue(.backgroundColor)
            setTitleColor(templateAppearanceValue(.foregroundColor), forState: .Normal)
            setTitle(templateAppearanceValue(.text), forState: .Normal)
            titleLabel?.font = templateAppearanceValue(.font)
            self.enabled = templateAppearanceValue(.clickable) ?? false
        }
    }
    
    override var highlighted: Bool {
        didSet {
            alpha = highlighted ? 0.5 : 1.0
        }
    }
    
    var roundingType: TextOnColorButtonRoundingType = .roundedRect(radius: 0)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch(roundingType) {
            case .pill: layer.cornerRadius = frame.size.v_roundCornerRadius
            case .roundedRect(let radius):layer.cornerRadius = radius
        }
    }
}
