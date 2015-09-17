//
//  LevelPolygonView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// A UIView subclass which draws a polygon with 6 sides
class LevelPolygonView: UIView {
    
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
            self.setNeedsDisplay()
        }
    }
    
    /// The polygon's border width
    var borderWidth: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// The polygon's stroke color
    var strokeColor = UIColor.whiteColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// The length of each side as a ratio of the total height
    var verticalSideLengthRatio: CGFloat = 0.5 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// How round the corners should be
    var cornerRadius: CGFloat = 14 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        
        let adjustedRect = CGRectInset(rect, borderWidth / 2, borderWidth / 2)
        
        let verticalSideLength: CGFloat = adjustedRect.height * verticalSideLengthRatio
        
        let insetHeight = adjustedRect.height
        let insetWidth = adjustedRect.width
        let verticalMidpoint = insetHeight / 2.0
        let horizontalMidpoint = insetWidth / 2.0
        let difference = insetHeight - verticalSideLength
        let aLength: CGFloat = difference / 2.0
        
        let path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, adjustedRect.origin.x, verticalMidpoint);
        CGPathAddArcToPoint(path, nil, adjustedRect.origin.x, aLength, horizontalMidpoint, adjustedRect.origin.y, cornerRadius);
        CGPathAddArcToPoint(path, nil, horizontalMidpoint, adjustedRect.origin.y, insetWidth, aLength, cornerRadius);
        CGPathAddArcToPoint(path, nil, insetWidth, aLength, insetWidth, aLength + verticalSideLength, cornerRadius);
        CGPathAddArcToPoint(path, nil, insetWidth, aLength + verticalSideLength, horizontalMidpoint, insetHeight, cornerRadius);
        CGPathAddArcToPoint(path, nil, horizontalMidpoint, insetHeight, adjustedRect.origin.x, aLength + verticalSideLength, cornerRadius);
        CGPathAddArcToPoint(path, nil, adjustedRect.origin.x, aLength + verticalSideLength, adjustedRect.origin.x, aLength, cornerRadius);
        
        CGPathCloseSubpath(path);
        
        let bezierPath = UIBezierPath(CGPath: path)
        
        bezierPath.lineWidth = borderWidth
        
        fillColor.setFill()
        strokeColor.setStroke()
        bezierPath.fill()
        bezierPath.stroke()
    }
}
