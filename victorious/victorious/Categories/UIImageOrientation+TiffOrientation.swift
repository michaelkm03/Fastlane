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
        case .Up:
            return 1
        case .Down:
            return 3
        case .Left:
            return 8
        case .Right:
            return 6
        case .UpMirrored:
            return 2
        case .DownMirrored:
            return 4
        case .LeftMirrored:
            return 5
        case .RightMirrored:
            return 7
        }
    }
}
