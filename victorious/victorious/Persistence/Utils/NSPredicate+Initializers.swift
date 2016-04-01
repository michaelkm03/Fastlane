//
//  NSPredicate+Initializers.swift
//  victorious
//
//  Created by Sharif Ahmed on 4/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension NSPredicate {
    
    class func predicateWithAssetMediaType(mediaType: PHAssetMediaType) -> NSPredicate? {
        
        guard mediaType != .Unknown else {
            return nil
        }
        
        return NSPredicate(format: "mediaType == \(mediaType.rawValue)", argumentArray: nil)
    }
}
