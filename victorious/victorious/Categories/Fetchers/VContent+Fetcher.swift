//
//  VContent+Fetcher.swift
//  victorious
//
//  Created by Vincent Ho on 5/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VContent {
    func contentType() -> ContentType? {
        guard let type = type else {
            return nil
        }
        return ContentType(rawValue: type)
    }
    
    func previewImageWithMinimumSize(minimumSize: CGSize) -> VContentPreview? {
        guard let previewImages = previewImages where previewImages.count != 0 else {
            return nil
        }
        
        let assetsByAscendingArea = previewImages.allObjects.sort() { (preview1, preview2) in
            let p1 = preview1 as! VContentPreview
            let p2 = preview2 as! VContentPreview
            let p1w = p1.width?.floatValue ?? 0
            let p1h = p1.height?.floatValue ?? 0
            let p2w = p2.width?.floatValue ?? 0
            let p2h = p2.height?.floatValue ?? 0
            
            return p1w * p1h < p2w * p2h
            } as! [VContentPreview]
        
        for asset in assetsByAscendingArea {
            let assetWidth = CGFloat(asset.width ?? 0)
            let assetHeight = CGFloat(asset.height ?? 0)
            
            if assetWidth >= minimumSize.width && assetHeight >= minimumSize.height {
                return asset
            }
        }
        return assetsByAscendingArea.last
    }
    
    func previewImageWithMinimumWidth(minimumWidth: CGFloat) -> VContentPreview? {
        guard let previewImages = previewImages where previewImages.count != 0 else {
            return nil
        }
        
        let assetsByAscendingArea = previewImages.allObjects.sort() { (preview1, preview2) in
            let p1 = preview1 as! VContentPreview
            let p2 = preview2 as! VContentPreview
            
            let p1w = p1.width?.floatValue ?? 0
            let p2w = p2.width?.floatValue ?? 0
            
            return p1w < p2w
            } as! [VContentPreview]
        
        for asset in assetsByAscendingArea {
            let assetWidth = CGFloat(asset.width ?? 0)
            if assetWidth >= minimumWidth {
                return asset
            }
        }
        return assetsByAscendingArea.last
    }
}
