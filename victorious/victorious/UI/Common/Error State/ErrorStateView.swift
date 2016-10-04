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
        return image(forKey: "errorIcon")?.withRenderingMode(.alwaysTemplate)
    }
    
    var title: String? {
        return string(forKey: "title")
    }
    
    var message: String? {
        return string(forKey: "message")
    }
    
    var titleFont: UIFont? {
        return font(forKey: "titleFont")
    }
    
    var messageFont: UIFont? {
        return font(forKey: "messageFont")
    }
    
    var titleColor: UIColor? {
        return color(forKey: "titleColor")
    }
    
    var messageColor: UIColor? {
        return color(forKey: "messageColor")
    }
    
    var iconColor: UIColor? {
        return color(forKey: "iconColor")
    }
    
    var backgroundColor: UIColor? {
        return color(forKey: "backgroundColor")
    }
}
