
//
//  TextOnPillButton.swift
//  victorious
//
//  Created by Vincent Ho on 10/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A template-styled button that displays text on top of a clear pill with outline.
@objc(VTextOnPillButton)
class TextOnPillButton: TouchableInsetAdjustableButton, TrackableButton {
    private struct Constants {
        static let addedWidth = CGFloat(20.0)
    }
    
    var dependencyManager: VDependencyManager? {
        didSet {
            hidden = dependencyManager == nil
            setTitleColor(templateAppearanceValue(.foregroundColor), forState: .Normal)
            setTitle(templateAppearanceValue(.text), forState: .Normal)
            titleLabel?.font = templateAppearanceValue(.font)
            userInteractionEnabled = templateAppearanceValue(.clickable) ?? false
            
            if
                let borderWidth: CGFloat = templateAppearanceValue(.borderWidth),
                let borderColor: UIColor = templateAppearanceValue(.backgroundColor)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.v_roundCornerRadius
    }
    
    // MARK: - Sizing
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(
            width: super.intrinsicContentSize().width + Constants.addedWidth,
            height: super.intrinsicContentSize().height
        )
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        return intrinsicContentSize()
    }
}
