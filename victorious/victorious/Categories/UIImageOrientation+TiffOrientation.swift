//
//  UIImageOrientation+TiffOrientation.swift
//  victorious
//
//  Created by Michael Sena on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

extension UIImageOrientation {
    func tiffOrientation() -> Int32 {
        switch (self)
        {
        case .Up:
            return Int32(1)
        case .Down:
            return Int32(3)
        case .Left:
            return Int32(8)
        case .Right:
            return Int32(6)
        case .UpMirrored:
            return Int32(2)
        case .DownMirrored:
            return Int32(4)
        case .LeftMirrored:
            return Int32(5)
        case .RightMirrored:
            return Int32(7)
        }
    }
}
