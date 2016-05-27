//
//  VPublishParameters+ConvenienceInit.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VPublishParameters {
    
    convenience init?(content: Content) {
        self.init()
        
        caption = content.text
        
        guard let mediaAsset = content.assets.first else {
            return nil
        }
        
        mediaToUploadURL = mediaAsset.url
        
        switch mediaAsset {
        case .youtube(_, _):
            return nil
        case .video(_, _):
            isGIF = false
            isVideo = true
        case .gif(_, _):
            isGIF = true
            isVideo = false
        case .image(_):
            isGIF = false
            isVideo = false
        }
    }
}
