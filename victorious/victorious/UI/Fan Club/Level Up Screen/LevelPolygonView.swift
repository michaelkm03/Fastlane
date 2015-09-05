//
//  LevelPolygonView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class LevelPolygonView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    func sharedInit() {
        self.backgroundColor = UIColor.clearColor()
    }
    
    var fillColor = UIColor.whiteColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var verticalSideLengthRatio: CGFloat = 0.5 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var cornerRadius: CGFloat = 14 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        
        let verticalSideLength: CGFloat = ceil(rect.height * verticalSideLengthRatio)
        let insetHeight = rect.height
        let insetWidth = rect.width
        let verticalMidpoint = ceil(insetHeight / 2.0)
        let horizontalMidpoint = ceil(insetWidth / 2.0)
        let difference = insetHeight - verticalSideLength
        let aLength: CGFloat = ceil(difference / 2.0)
        
        let path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, rect.origin.x, verticalMidpoint);
        CGPathAddArcToPoint(path, nil, rect.origin.x, aLength, horizontalMidpoint, rect.origin.y, cornerRadius);
        CGPathAddArcToPoint(path, nil, horizontalMidpoint, rect.origin.y, insetWidth, aLength, cornerRadius);
        CGPathAddArcToPoint(path, nil, insetWidth, aLength, insetWidth, aLength + verticalSideLength, cornerRadius);
        CGPathAddArcToPoint(path, nil, insetWidth, aLength + verticalSideLength, horizontalMidpoint, insetHeight, cornerRadius);
        CGPathAddArcToPoint(path, nil, horizontalMidpoint, insetHeight, rect.origin.x, aLength + verticalSideLength, cornerRadius);
        CGPathAddArcToPoint(path, nil, rect.origin.x, aLength + verticalSideLength, rect.origin.x, aLength, cornerRadius);
        
        CGPathCloseSubpath(path);
        
        let bezierPath = UIBezierPath(CGPath: path)
        
        fillColor.setFill()
        bezierPath.fill()
    }
}
