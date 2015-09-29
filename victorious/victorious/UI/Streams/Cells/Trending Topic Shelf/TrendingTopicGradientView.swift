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
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = bounds
            gradient.colors = [primaryColor.colorWithAlphaComponent(CGFloat(gradientAlphas.0)).CGColor,
                primaryColor.colorWithAlphaComponent(CGFloat(gradientAlphas.1)).CGColor,
                primaryColor.colorWithAlphaComponent(CGFloat(gradientAlphas.2)).CGColor]
            self.layer.insertSublayer(gradient, atIndex: 0)
            gradientLayer = gradient
        }
    }
}
