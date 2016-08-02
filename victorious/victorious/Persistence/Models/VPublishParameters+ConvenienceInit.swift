//
//  VPublishParameters+ConvenienceInit.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VPublishParameters {
    
    convenience init?(content: ContentModel) {
        self.init()
        
        guard
            let mediaAsset = content.assets.first,
            let mediaPreview = content.largestPreviewImage
            where mediaAsset.contentType != .text && mediaAsset.contentType != .link
        else {
            return nil
        }
        
        width = Int(mediaPreview.size.width)
        height = Int(mediaPreview.size.height)
        
        caption = content.text
        source = mediaAsset.source
        
        isGIF = mediaAsset.contentType == .gif
        isVideo = mediaAsset.contentType == .video
        
        if isGIF {
            assetRemoteId = mediaAsset.externalID
        }
        else {
            mediaToUploadURL = mediaAsset.url
        }
    }
}
