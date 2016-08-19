//
//  CGRect+Aspect.swift
//  victorious
//
//  Created by Michael Sena on 11/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

extension CGRect {
    
    // MARK: - Initializing
    
    init(center: CGPoint, size: CGSize) {
        self.init(
            origin: CGPoint(
                x: center.x - size.width / 2.0,
                y: center.y - size.height / 2.0
            ),
            size: size
        )
    }
    
    // MARK: - Resizing
    
    func v_aspectFit(toRect: CGRect) -> CGRect {
        let fromAspectRatio = self.size.width / self.size.height
        let toAspectRatio = toRect.size.width / toRect.size.height
        
        var fitRect = toRect
        
        if fromAspectRatio > toAspectRatio {
            fitRect.size.height = toRect.size.width / fromAspectRatio
            fitRect.origin.y += (toRect.size.height - fitRect.size.height) * 0.5
        } else {
            fitRect.size.width = toRect.size.height  * fromAspectRatio;
            fitRect.origin.x += (toRect.size.width - fitRect.size.width) * 0.5
        }
        
        return CGRectIntegral(fitRect)
    }
    
    func v_aspectFill(toRect: CGRect) -> CGRect {
        let fromAspectRatio = self.size.width / self.size.height
        let toAspectRatio = toRect.size.width / toRect.size.height
        
        var fitRect = toRect
        
        if fromAspectRatio > toAspectRatio {
            fitRect.size.width = toRect.size.height  * fromAspectRatio
            fitRect.origin.x += (toRect.size.width - fitRect.size.width) * 0.5
        }
        else {
            fitRect.size.height = toRect.size.width / fromAspectRatio
            fitRect.origin.y += (toRect.size.height - fitRect.size.height) * 0.5
        }
        
        return CGRectIntegral(fitRect)
    }
    
    func insetBy(insets: UIEdgeInsets) -> CGRect {
        var rect = self
        rect.origin.x += insets.left
        rect.origin.y += insets.top
        rect.size.width -= insets.horizontal
        rect.size.height -= insets.vertical
        return rect
    }
    
    // MARK: - Geometric properties
    
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}