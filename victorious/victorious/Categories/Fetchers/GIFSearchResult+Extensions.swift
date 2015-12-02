//
//  GIFSearch+Extensions.swift
//  victorious
//
//  Created by Patrick Lynch on 7/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension VGIFSearchResult {
    
    /// The aspect ratio of the assets
    var aspectRatio: CGFloat {
        return CGFloat(width) / CGFloat(height)
    }
    
    /// A `CGSize` value created using the assets width and height
    var assetSize: CGSize {
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
}
