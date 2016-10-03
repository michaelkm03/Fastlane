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
            hidden = dependencyManager == nil
            backgroundColor = templateAppearanceValue(.backgroundColor)
            setTitleColor(templateAppearanceValue(.foregroundColor), forState: .Normal)
            setTitle(templateAppearanceValue(.text), forState: .Normal)
            titleLabel?.font = templateAppearanceValue(.font)
            userInteractionEnabled = templateAppearanceValue(.clickable) ?? false
            
            if
                let borderWidth: CGFloat = templateAppearanceValue(.borderWidth),
                let borderColor: UIColor = templateAppearanceValue(.borderColor)
            {
                layer.borderWidth = borderWidth
                layer.borderColor = borderColor.CGColor
            }
        }
    }
    
    override var highlighted: Bool {
        didSet {
            alpha = highlighted ? 0.5 : 1.0
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
    
    override func intrinsicContentSize() -> CGSize {
        if needsPadding {
            return CGSize(
                width: super.intrinsicContentSize().width + Constants.addedWidth,
                height: super.intrinsicContentSize().height
            )
        }
        else {
            return super.intrinsicContentSize()
        }
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        return intrinsicContentSize()
    }
}
