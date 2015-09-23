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
    
    /// Whether or not the stroke is being animated
    private(set) var isAnimating = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureShapeLayer()
    }
    
    private func configureShapeLayer() {
        
        shapeLayer.removeFromSuperlayer()
        
        let rect = bounds
        
        let sideLength: CGFloat = rect.height * verticalSideLengthRatio
        let b: CGFloat = (rect.height - sideLength) / 2
        
        let topPoint = CGPointMake(rect.size.width / 2, 0)
        let firstLeftPoint = CGPointMake(0, b)
        let secondLeftPoint = CGPointMake(0, b + sideLength)
        let firstRightPoint = CGPointMake(rect.size.width, b)
        let secondRightPoint = CGPointMake(rect.size.width, b + sideLength)
        let bottomPoint = CGPointMake(rect.size.width / 2, rect.size.height)
        
        // Create two lines representing the top two lines of the hexagon
        let topLeftLine = Line(start: firstLeftPoint, end: topPoint)
        let topRightLine = Line(start: topPoint, end: firstRightPoint)
        
        // Create two inset lines so we can find the intersect
        let insetLeftLine = topLeftLine.offsetWithRadius(cornerRadius)
        let insetRightLine = topRightLine.offsetWithRadius(cornerRadius)
        
        // Find the intersect point. This is the center of the corner radius circle
        let intersect = insetLeftLine.intersect(insetRightLine)
        
        // Create a new path
        let hexagonPath = CGPathCreateMutable();
        
        // Move to the top most point of the hexagon
        CGPathMoveToPoint(hexagonPath, nil, rect.size.width / 2, intersect.y - cornerRadius)
        
        // Draw half the arc down to the angle of the top right line
        CGPathAddArc(hexagonPath, nil, intersect.x, intersect.y, cornerRadius, -CGFloat(M_PI_2), -CGFloat(M_PI_2) + topRightLine.angle , false)
        
        // Continue drawing arcs
        CGPathAddArcToPoint(hexagonPath, nil, firstRightPoint.x, firstRightPoint.y, secondRightPoint.x, secondRightPoint.y, cornerRadius)
        CGPathAddArcToPoint(hexagonPath, nil, secondRightPoint.x, secondRightPoint.y, bottomPoint.x, bottomPoint.y, cornerRadius)
        CGPathAddArcToPoint(hexagonPath, nil, bottomPoint.x, bottomPoint.y, secondLeftPoint.x, secondLeftPoint.y, cornerRadius)
        CGPathAddArcToPoint(hexagonPath, nil, secondLeftPoint.x, secondLeftPoint.y, firstLeftPoint.x, firstLeftPoint.y, cornerRadius)
        CGPathAddArcToPoint(hexagonPath, nil, firstLeftPoint.x, firstLeftPoint.y, topPoint.x, topPoint.y, cornerRadius)
        
        // Draw the last half of the first arc in order to complete the path
        CGPathAddArc(hexagonPath, nil, intersect.x, intersect.y, cornerRadius, -CGFloat(M_PI_2) + topLeftLine.angle, -CGFloat(M_PI_2), false)
        
        let bezierPath = UIBezierPath(CGPath: hexagonPath)
        bezierPath.lineCapStyle = .Round
        
        shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.CGPath
        // For animation purposes, offset the start of the stroke so that there's still a small
        // gap between the beginning and the end of the stroke when the user si very close to
        // the next level
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0
        shapeLayer.lineWidth = borderWidth
        shapeLayer.strokeColor = strokeColor.CGColor
        shapeLayer.fillColor = fillColor.CGColor
        shapeLayer.lineCap = kCALineCapRound;
        self.layer.addSublayer(shapeLayer)
    }
    
    func animateBorder(endValue: CGFloat, duration: NSTimeInterval) {
        isAnimating = true
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.fromValue = 0
        basicAnimation.toValue = endValue
        basicAnimation.duration = duration
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.removedOnCompletion = false
        basicAnimation.delegate = self
        shapeLayer.addAnimation(basicAnimation, forKey: "strokeEndAnimation")
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        isAnimating = false
    }
}

// Represents a line between two points
struct Line {
    var start: CGPoint
    var end: CGPoint
    var angle: CGFloat {
        return atan2(end.y - start.y, end.x - start.x)
    }
    
    // Returns a line with the same slope that is offset by a certain radius
    func offsetWithRadius(radius: CGFloat) -> Line {
        let offset = CGVectorMake(-sin(angle) * radius, cos(angle) * radius)
        
        let offsetStart = CGPointMake(start.x + offset.dx, start.y + offset.dy)
        let offsetEnd = CGPointMake(end.x + offset.dx, end.y + offset.dy)
        
        return Line(start: offsetStart, end: offsetEnd)
    }
    
    // Returns the intersect this line with another
    func intersect(secondLine: Line) -> CGPoint {
        
        let x1 = self.start.x
        let x2 = self.end.x
        let x3 = secondLine.start.x
        let x4 = secondLine.end.x
        
        let y1 = self.start.y
        let y2 = self.end.y
        let y3 = secondLine.start.y
        let y4 = secondLine.end.y
        
        let intersectX = ((x1*y2-y1*x2)*(x3-x4) - (x1-x2)*(x3*y4-y3*x4)) / ((x1-x2)*(y3-y4) - (y1-y2)*(x3-x4))
        let intersectY = ((x1*y2-y1*x2)*(y3-y4) - (y1-y2)*(x3*y4-y3*x4)) / ((x1-x2)*(y3-y4) - (y1-y2)*(x3-x4))
        
        return CGPointMake(intersectX, intersectY)
    }
}
