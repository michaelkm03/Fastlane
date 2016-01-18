//
//  String+ThumbnailPath.swift
//  victorious
//
//  Created by Patrick Lynch on 1/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension String {
    
    var v_thumbnailPathForVideoAtPath: String? {
        
        guard let url = NSURL(string:self) else {
            return nil
        }
        
        guard !self.v_hasImageExtension() else {
            return self
        }
        
        let asset = AVAsset(URL: url)
        let assetGenerator = AVAssetImageGenerator(asset: asset)
        let time = CMTimeMake(asset.duration.value / 2, asset.duration.timescale)
        let anImageRef: CGImageRef?
        do {
            anImageRef = try assetGenerator.copyCGImageAtTime(time, actualTime: nil)
        } catch {
            return nil
        }
        
        guard let imageRef = anImageRef else {
            return nil
        }
        let previewImage = UIImage(CGImage: imageRef)
        
        let tempDirectory = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let tempFile = tempDirectory.URLByAppendingPathComponent(NSUUID().UUIDString).URLByAppendingPathExtension(VConstantMediaExtensionJPG)
        if let imgData = UIImageJPEGRepresentation(previewImage, VConstantJPEGCompressionQuality) {
            imgData.writeToURL(tempFile, atomically: false )
            return tempFile.absoluteString
        }
        
        return nil
    }
}
