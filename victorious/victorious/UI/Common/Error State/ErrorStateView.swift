//
//  ErrorStateView.swift
//  victorious
//
//  Created by Vincent Ho on 6/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ErrorStateView: UIView {
    fileprivate struct Constants {
        static let cornerRadii = CGSize(width: 10, height: 10)
    }
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    fileprivate var lastBounds: CGRect? {
        didSet {
            if lastBounds != oldValue {
                let maskPath = UIBezierPath(
                    roundedRect: bounds,
                    byRoundingCorners: [.bottomRight, .bottomLeft],
                    cornerRadii: Constants.cornerRadii
                )
                
                let maskLayer = CAShapeLayer()
                maskLayer.frame = bounds
                maskLayer.path = maskPath.cgPath
                
                layer.mask = maskLayer
            }
        }
    }

    override func layoutSubviews() {
        lastBounds = bounds
    }
    
    var dependencyManager: VDependencyManager? {
        didSet {
            titleLabel.text = dependencyManager?.title
            titleLabel.textColor = dependencyManager?.titleColor
            titleLabel.font = dependencyManager?.titleFont
            
            messageLabel.text = dependencyManager?.message
            messageLabel.textColor = dependencyManager?.messageColor
            messageLabel.font = dependencyManager?.messageFont
            
            backgroundColor = dependencyManager?.backgroundColor
            
            iconImageView.image = dependencyManager?.errorIcon
            iconImageView.tintColor = dependencyManager?.iconColor
        }
    }
}

private extension VDependencyManager {
    var errorIcon: UIImage? {
        return imageForKey("errorIcon")?.imageWithRenderingMode(.AlwaysTemplate)
    }
    
    var title: String? {
        return stringForKey("title")
    }
    
    var message: String? {
        return stringForKey("message")
    }
    
    var titleFont: UIFont? {
        return fontForKey("titleFont")
    }
    
    var messageFont: UIFont? {
        return fontForKey("messageFont")
    }
    
    var titleColor: UIColor? {
        return colorForKey("titleColor")
    }
    
    var messageColor: UIColor? {
        return colorForKey("messageColor")
    }
    
    var iconColor: UIColor? {
        return colorForKey("iconColor")
    }
    
    var backgroundColor: UIColor? {
        return colorForKey("backgroundColor")
    }
}
