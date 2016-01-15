//
//  MediaAttachment+PublishParameters.swift
//  victorious
//
//  Created by Patrick Lynch on 1/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension MediaAttachment {
    
    init?(publishParameters: VPublishParameters) {
        guard publishParameters.width > 0 && publishParameters.height > 0,
            let url = publishParameters.mediaToUploadURL,
            let thumbnailURL = MediaAttachment.localImageURLForVideoAtURL( url ) else {
                return nil
        }
        self.size = CGSize( width: CGFloat(publishParameters.width), height: CGFloat(publishParameters.height) )
        self.url = url
        self.thumbnailURL = thumbnailURL
        self.type = .GIF
        self.isGIFStyle = false // FIXME: Do we need this with `type` as GIF??
        self.shouldAutoplay = false // FIXME
    }
    
    private static func localImageURLForVideoAtURL( url: NSURL ) -> NSURL? {
        guard !url.v_hasImageExtension() else {
            return url
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
            return NSURL(fileURLWithPath: tempFile.absoluteString)
        }
        
        return nil
    }
}
