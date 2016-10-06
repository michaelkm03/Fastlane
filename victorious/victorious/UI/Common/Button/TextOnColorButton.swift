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
    private struct Constants {
        static let addedWidth = CGFloat(20.0)
    }

    var dependencyManager: VDependencyManager? {
        didSet {
            isHidden = dependencyManager == nil
            backgroundColor = templateAppearanceValue(appearance: .backgroundColor)
            setTitleColor(templateAppearanceValue(appearance: .foregroundColor), for: .normal)
            setTitle(templateAppearanceValue(appearance: .text), for: .normal)
            titleLabel?.font = templateAppearanceValue(appearance: .font)
            isUserInteractionEnabled = templateAppearanceValue(appearance: .clickable) ?? false
            
            if
                let borderWidth: CGFloat = templateAppearanceValue(appearance: .borderWidth),
                let borderColor: UIColor = templateAppearanceValue(appearance: .borderColor)
            {
                layer.borderWidth = borderWidth
                layer.borderColor = borderColor.cgColor
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.5 : 1.0
        }
    }
    
    var needsPadding = false {
        didSet {
            setNeedsDisplay()
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
    
    // MARK: - Sizing
    
    override var intrinsicContentSize: CGSize {
        if needsPadding {
            return CGSize(
                width: super.intrinsicContentSize.width + Constants.addedWidth,
                height: super.intrinsicContentSize.height
            )
        }
        else {
            return super.intrinsicContentSize
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return intrinsicContentSize
    }
}
