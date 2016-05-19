//
//  VContentPreviewAsset+Fetcher.swift
//  victorious
//
//  Created by Vincent Ho on 5/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VContentPreviewAsset {
    var area: CGFloat {
        guard let width = width,
            height = height else {
                return CGFloat(0)
        }
        return CGFloat(width) * CGFloat(height)
    }
}