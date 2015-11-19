//
//  CGRect+Aspect.swift
//  victorious
//
//  Created by Michael Sena on 11/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

extension CGRect {
    
    public func v_aspectFit(toRect: CGRect) -> CGRect {
        let fromAspectRatio = self.size.width / self.size.height;
        let toAspectRatio = toRect.size.width / toRect.size.height;
        
        var fitRect = toRect
        
        if (fromAspectRatio > toAspectRatio) {
            fitRect.size.height = toRect.size.width / fromAspectRatio;
            fitRect.origin.y += (toRect.size.height - fitRect.size.height) * 0.5;
        } else {
            fitRect.size.width = toRect.size.height  * fromAspectRatio;
            fitRect.origin.x += (toRect.size.width - fitRect.size.width) * 0.5;
        }
        
        return CGRectIntegral(fitRect)
    }
    
    public func v_aspectFill(toRect: CGRect) -> CGRect {
        let fromAspectRatio = self.size.width / self.size.height;
        let toAspectRatio = toRect.size.width / toRect.size.height;
        
        var fitRect = toRect
        
        if (fromAspectRatio > toAspectRatio) {
            fitRect.size.width = toRect.size.height  * fromAspectRatio;
            fitRect.origin.x += (toRect.size.width - fitRect.size.width) * 0.5;
        } else {
            fitRect.size.height = toRect.size.width / fromAspectRatio;
            fitRect.origin.y += (toRect.size.height - fitRect.size.height) * 0.5;
        }
        
        return CGRectIntegral(fitRect)
    }

}