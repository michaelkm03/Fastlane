//
//  VImageAsset+Fetcher.swift
//  victorious
//
//  Created by Vincent Ho on 5/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import CoreData

extension VImageAsset {
    
    ///  The area of the image in pixels squared.  Width * height;
    
    func area() -> CGFloat {
        return CGFloat(width) * CGFloat(height)
    }
    
    ///  Return YES if the height and width of the image asset are less than or equal
    /// to the width and height of the provided size.
    
    func fitsWithinSize(size: CGSize) -> Bool {
        return CGFloat(width) <= size.width && CGFloat(height) <= size.height
    }
    
    /// Return YES if the height and width of the image asset are greater than or equal
    /// to the width and height of the provided size.

    func encompassesSize(size: CGSize) -> Bool {
        return CGFloat(width) >= size.width && CGFloat(height) >= size.height
    }
    
}
