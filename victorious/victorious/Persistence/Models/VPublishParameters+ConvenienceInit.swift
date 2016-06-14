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
        
        caption = content.text
        
        guard let mediaAsset = content.assetModels.first else {
            return nil
        }
        
        mediaToUploadURL = mediaAsset.url
        
        switch mediaAsset.contentType {
            case .video:
                isGIF = false
                isVideo = true
            case .gif:
                isGIF = true
                isVideo = false
            case .image:
                isGIF = false
                isVideo = false
            case .text, .link:
                return nil
        }
    }
}
