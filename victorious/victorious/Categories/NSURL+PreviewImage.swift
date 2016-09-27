//
//  NSURL+PreviewImage.swift
//  victorious
//
//  Created by Sharif Ahmed on 4/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension URL {
    
    /// Creates and returns an image generated from the first
    /// moment of the video found at this url.
    var v_videoPreviewImage: UIImage? {
        let asset = AVURLAsset(URL: self)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        return try? UIImage(CGImage: imageGenerator.copyCGImageAtTime(kCMTimeZero, actualTime: nil))
    }
}
