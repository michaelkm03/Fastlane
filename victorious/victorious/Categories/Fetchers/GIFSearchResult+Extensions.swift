//
//  GIFSearch+Extensions.swift
//  victorious
//
//  Created by Patrick Lynch on 7/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension GIFSearchResult {
    
    /// The aspect ratio of the assets
    var aspectRatio: CGFloat {
        return CGFloat(self.width.integerValue) / CGFloat(self.height.integerValue)
    }
    
    /// A `CGSize` value created using the assets width and height
    var assetSize: CGSize {
        return CGSize(width: CGFloat(self.width.integerValue), height: CGFloat(self.height.integerValue) )
    }
}