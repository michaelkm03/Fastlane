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
    
    /// Adapts the view controller specific VPublishParameters into a Victorious IOS SDK compliant
    /// MediaAttachment to submit to a network request such as commenting or sending messages.
    init?(publishParameters: VPublishParameters) {
        guard let url = publishParameters.mediaToUploadURL else {
            return nil
        }
        size = CGSize( width: CGFloat(publishParameters.width), height: CGFloat(publishParameters.height) )
        self.url = url
        
        if publishParameters.isGIF {
            type = .GIF
            isGIFStyle = true
            shouldAutoplay = true
            // iOS client is only capable of creating .mp4 assets
            formats = [ MediaAttachment.Format(url: publishParameters.mediaToUploadURL ?? NSURL(string: "")!, mimeType: .MP4)]
        } else if publishParameters.isVideo {
            type = .Video
            isGIFStyle = false
            shouldAutoplay = false
            // iOS client is only capable of creating .mp4 assets
            formats = [ MediaAttachment.Format(url: publishParameters.mediaToUploadURL ?? NSURL(string: "")!, mimeType: .MP4)]
        } else {
            type = .Image
            isGIFStyle = false
            shouldAutoplay = false
            formats = nil
        }
        
        thumbnailURL = nil
    }
    
    /// Snapshot the asset and save the image to a URL and return it.
    /// This can be performance intensive depending on the media url of the receiver,
    /// so call this function wisely.
    func createThumbnailImage() -> NSURL? {
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
