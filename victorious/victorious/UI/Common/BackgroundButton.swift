//
//  BackgroundButton.swift
//  victorious
//
//  Created by Jarod Long on 7/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// A button that displays a colored background behind its content via the `backgroundColor` property.
class BackgroundButton: UIButton {
    private struct Constants {
        static let addedWidth = CGFloat(20.0)
        static let height = CGFloat(30.0)
        static let cornerRadius = CGFloat(6.0)
        static let defaultFont = UIFont.systemFontOfSize(14.0, weight: UIFontWeightSemibold)
        static let defaultTintColor = UIColor(white: 1.0, alpha: 1.0)
        static let defaultBackgroundColor = UIColor(white: 1.0, alpha: 0.2)
    }
    
    // MARK: - Initializing
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        layer.cornerRadius = Constants.cornerRadius
        titleLabel?.font = Constants.defaultFont
        tintColor = Constants.defaultTintColor
        backgroundColor = Constants.defaultBackgroundColor
    }
    
    // MARK: - Sizing
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(
            width: super.intrinsicContentSize().width + Constants.addedWidth,
            height: Constants.height
        )
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        return intrinsicContentSize()
    }
}
