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
    
    private var shapeLayer: CAShapeLayer {
        return layer as! CAShapeLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    func sharedInit() {
        backgroundColor = UIColor.clearColor()
        strokeEnd = 0
    }
    
    override class func layerClass() -> AnyClass {
        return CAShapeLayer.self
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
    
    // A value between 0 and 1 representing the shape layer's stroke end
    var strokeEnd: CGFloat {
        get {
            return shapeLayer.strokeEnd
        }
        set {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            shapeLayer.strokeEnd = newValue
            CATransaction.commit()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureShapeLayer()
    }
    
    private func configureShapeLayer() {
        
        let rect = bounds
        
        if rect == CGRectZero {
            return
        }
        
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
        let insetLeftLine = topLeftLine.offset(radius: cornerRadius)
        let insetRightLine = topRightLine.offset(radius: cornerRadius)
        
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
        
        shapeLayer.path = bezierPath.CGPath
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = strokeEnd
        shapeLayer.lineWidth = borderWidth
        shapeLayer.strokeColor = strokeColor.CGColor
        shapeLayer.fillColor = fillColor.CGColor
        shapeLayer.lineCap = kCALineCapRound;
    }
}

// Represents a line between two points
struct Line {
    var start: CGPoint
    var end: CGPoint
    var angle: CGFloat {
        return atan2(end.y - start.y, end.x - start.x)
    }
    
    // Returns a new line with the same slope that is offset by a certain radius
    func offset(radius radius: CGFloat) -> Line {
        let offset = CGPointMake(-sin(angle) * radius, cos(angle) * radius)
        
        let offsetStart = start + offset
        let offsetEnd = end + offset
        
        return Line(start: offsetStart, end: offsetEnd)
    }
    
    // Returns the intersect this line with another
    func intersect(secondLine: Line) -> CGPoint {
        
        let x1 = start.x
        let x2 = end.x
        let x3 = secondLine.start.x
        let x4 = secondLine.end.x
        
        let y1 = start.y
        let y2 = end.y
        let y3 = secondLine.start.y
        let y4 = secondLine.end.y
        
        let intersectX = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4))
        let intersectY = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4))
        
        return CGPointMake(intersectX, intersectY)
    }
}
