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
    
    // Width to height aspect ratio of the content
    var aspectRatio: CGFloat {
        guard let preview = previewImages?.allObjects.first as? VContentPreview,
            let height = preview.height?.integerValue,
            let width = preview.width?.integerValue
            where height > 0 && width > 0 else {
                return 1.0
        }
        return CGFloat(width) / CGFloat(height)
    }
    
    func previewImageWithMinimumSize(minimumSize: CGSize) -> VContentPreview? {
        guard let previewImages = previewImages as? Set<VContentPreview> else {
            return nil
        }
        
        let assetsByAscendingArea = previewImages.sort { $0.area < $1.area }
        
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
        
        guard let previewImages = previewImages as? Set<VContentPreview> else {
            return nil
        }
        
        let assetsByAscendingArea = previewImages.sort { $0.width?.floatValue < $1.width?.floatValue }
        
        for asset in assetsByAscendingArea where CGFloat(asset.width ?? 0) >= minimumWidth {
            return asset
        }
        return assetsByAscendingArea.last
    }
}
