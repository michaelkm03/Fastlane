//
//  CGSize+Geometry.swift
//  victorious
//
//  Created by Jarod Long on 5/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import CoreGraphics

extension CGSize {
    // MARK: - Geometric properties
    
    var area: CGFloat {
        return width * height
    }
    
    var aspectRatio: CGFloat {
        return width / height
    }
    
    // MARK: - Containment
    
    func contains(size: CGSize) -> Bool {
        return width >= size.width && height >= size.height
    }
    
    func fits(in size: CGSize) -> Bool {
        return size.contains(self)
    }
}
