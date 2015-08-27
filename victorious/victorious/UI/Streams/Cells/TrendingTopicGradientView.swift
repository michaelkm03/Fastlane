//
//  TrendingTopicGradientView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class TrendingTopicGradientView: UIView {
    
    // A tuple representing the alpha values of each of the three stages in the gradient
    var gradientAlphas = (0.05, 0.3, 0.05) {
        didSet {
            drawGradient()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var gradientLayer: CAGradientLayer?
    
    // The primary color of the gradient
    var primaryColor: UIColor? {
        didSet {
            drawGradient()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawGradient()
    }
    
    private func drawGradient() {
        gradientLayer?.removeFromSuperlayer()
        if let primaryColor = primaryColor {
            var gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = self.bounds
            gradient.colors = [primaryColor.colorWithAlpha(gradientAlphas.0).CGColor,
                primaryColor.colorWithAlpha(gradientAlphas.1).CGColor,
                primaryColor.colorWithAlpha(gradientAlphas.2).CGColor]
            self.layer.insertSublayer(gradient, atIndex: 0)
            gradientLayer = gradient
        }
    }
}

extension UIColor {
    func colorWithAlpha(alpha: Double) -> UIColor {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: r, green: g, blue: b, alpha: CGFloat(alpha))
    }
}