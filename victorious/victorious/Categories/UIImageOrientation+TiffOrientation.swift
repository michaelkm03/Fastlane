

//
//  UIImageOrientation+TiffOrientation.swift
//  victorious
//
//  Created by Michael Sena on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

extension UIImageOrientation {
    
    /// Converts to TIFF Tag Orientation. See documentation: http://partners.adobe.com/public/developer/en/tiff/TIFF6.pdf
    func tiffOrientation() -> Int32 {
        switch (self) {
        case .up:
            return 1
        case .down:
            return 3
        case .left:
            return 8
        case .right:
            return 6
        case .upMirrored:
            return 2
        case .downMirrored:
            return 4
        case .leftMirrored:
            return 5
        case .rightMirrored:
            return 7
        }
    }
}
