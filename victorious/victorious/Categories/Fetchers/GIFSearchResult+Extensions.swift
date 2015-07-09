//
//  GIFSearch+Extensions.swift
//  victorious
//
//  Created by Patrick Lynch on 7/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension GIFSearchResult {
    var aspectRatio: CGFloat {
        return CGFloat(self.width.integerValue) / CGFloat(self.height.integerValue)
    }
    
    var assetSize: CGSize {
        return CGSize(width: CGFloat(self.width.integerValue), height: CGFloat(self.height.integerValue) )
    }
}