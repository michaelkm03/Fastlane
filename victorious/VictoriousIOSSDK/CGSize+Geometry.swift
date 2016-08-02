//
//  CGSize+Geometry.swift
//  VictoriousIOSSDK
//
//  Created by Jarod Long on 5/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import CoreGraphics

extension CGSize {
    // MARK: - Geometric properties
    
    public var area: CGFloat {
        return width * height
    }
    
    public var aspectRatio: CGFloat? {
        if height == 0.0 {
            return nil
        }
        
        return width / height
    }
    
    // MARK: - Containment
    
    public func contains(size: CGSize) -> Bool {
        return width >= size.width && height >= size.height
    }
    
    public func fits(in size: CGSize) -> Bool {
        return size.contains(self)
    }
}
