//
//  HexagonView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// A UIView subclass which draws a hexagon
class HexagonView: UIView {
    
    private var shapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    func sharedInit() {
        self.backgroundColor = UIColor.clearColor()
    }
    
    /// The polygon's fill color
    var fillColor = UIColor.whiteColor() {
        didSet {
            configureShapeLayer()
        }
    }
    
    /// The polygon's border width
    var borderWidth: CGFloat = 0 {
        didSet {
            configureShapeLayer()
        }
    }
    
    /// The polygon's stroke color
    var strokeColor = UIColor.whiteColor() {
        didSet {
            configureShapeLayer()
        }
    }
    
    /// The length of each side as a ratio of the total height
    var verticalSideLengthRatio: CGFloat = 0.5 {
        didSet {
            configureShapeLayer()
        }
    }
    
    /// How round the corners should be
    var cornerRadius: CGFloat = 14 {
        didSet {
            configureShapeLayer()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureShapeLayer()
    }
    
    private func configureShapeLayer() {
        
        shapeLayer.removeFromSuperlayer()
        
        let adjustedRect = bounds
        
        let verticalSideLength: CGFloat = adjustedRect.height * verticalSideLengthRatio
        
        let insetHeight = adjustedRect.height
        let insetWidth = adjustedRect.width
        let horizontalMidpoint = insetWidth / 2.0
        let difference = insetHeight - verticalSideLength
        let aLength: CGFloat = difference / 2.0
        
        let path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, horizontalMidpoint, adjustedRect.origin.y);
        CGPathAddLineToPoint(path, nil, horizontalMidpoint + horizontalMidpoint / 2, aLength / 2)
        CGPathAddArcToPoint(path, nil, insetWidth, aLength, insetWidth, aLength + verticalSideLength, cornerRadius);
        CGPathAddArcToPoint(path, nil, insetWidth, aLength + verticalSideLength, horizontalMidpoint, insetHeight, cornerRadius);
        CGPathAddArcToPoint(path, nil, horizontalMidpoint, insetHeight, adjustedRect.origin.x, aLength + verticalSideLength, cornerRadius);
        CGPathAddArcToPoint(path, nil, adjustedRect.origin.x, aLength + verticalSideLength, adjustedRect.origin.x, aLength, cornerRadius);
        CGPathAddArcToPoint(path, nil, adjustedRect.origin.x, aLength, horizontalMidpoint, adjustedRect.origin.y, cornerRadius);
        CGPathAddArcToPoint(path, nil, horizontalMidpoint, adjustedRect.origin.y, insetWidth, aLength, cornerRadius);
        
//        CGPathCloseSubpath(path)
        
        let bezierPath = UIBezierPath(CGPath: path)
        bezierPath.lineCapStyle = .Round
        
        shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.CGPath
        shapeLayer.strokeStart = 0.01
        shapeLayer.strokeEnd = 0
        shapeLayer.lineWidth = borderWidth
        shapeLayer.strokeColor = strokeColor.CGColor
        shapeLayer.fillColor = fillColor.CGColor
        shapeLayer.lineCap = kCALineCapRound;
        self.layer.addSublayer(shapeLayer)
    }
    
    func animateBorder(endValue: CGFloat, duration: NSTimeInterval) {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.fromValue = 0.1
        basicAnimation.toValue = endValue
        basicAnimation.duration = duration
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.removedOnCompletion = false
        shapeLayer.addAnimation(basicAnimation, forKey: "strokeEndAnimation")
    }
}
