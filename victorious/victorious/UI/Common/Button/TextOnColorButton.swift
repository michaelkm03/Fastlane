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
class TextOnColorButton: TouchableInsetAdjustableButton, TrackableButton {
    var dependencyManager: VDependencyManager? {
        didSet {
            isHidden = dependencyManager == nil
            backgroundColor = templateAppearanceValue(appearance: .backgroundColor)
            setTitleColor(templateAppearanceValue(appearance: .foregroundColor), for: .normal)
            setTitle(templateAppearanceValue(appearance: .text), for: .normal)
            let font: UIFont? = templateAppearanceValue(appearance: .font)
            titleLabel?.font = font
            isUserInteractionEnabled = templateAppearanceValue(appearance: .clickable) ?? false
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.5 : 1.0
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
