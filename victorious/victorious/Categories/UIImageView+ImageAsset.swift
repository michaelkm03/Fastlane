//
//  UIImageView+ImageAsset.swift
//  victorious
//
//  Created by Tian Lan on 7/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import SDWebImage

typealias ImageCompletion = ((UIImage?, NSError?)->())?

extension UIImageView {
    private static let blurredImageCachePathExtension = "blurred"
    /// Downloads the image from the image asset or grabs the cached version to return in the completion block
    func getImageAsset(imageAsset: ImageAssetModel, blurRadius: CGFloat = 0, completion: ImageCompletion) {
        image = nil
        
        let imageBlurBlock: (UIImage?, NSURL?, NSError?)->() = { [weak self] image, url, error in
            guard let image = image else {
                completion?(nil, error)
                return
            }
            
            if blurRadius != 0 {
                self?.applyBlur(to: image, with: url, radius: blurRadius, completion: completion)
            }
            else {
                completion?(image, error)
            }
        }
        
        switch imageAsset.imageSource {
            case .remote(let url):
                sd_setImageWithURL(
                    url,
                    placeholderImage: image,
                    options: .AvoidAutoSetImage
                ) { image, error, _, url in
                    imageBlurBlock(image, url, error)
                }
            case .local(let image):
                imageBlurBlock(image, nil, nil)
        }
    }
    
    func cachedBlurredImage(for url: NSURL, blurRadius: CGFloat) -> UIImage? {
        let key = blurredImageKey(for: url, blurRadius: blurRadius)
        return SDWebImageManager.sharedManager().imageCache.imageFromMemoryCacheForKey(key)
    }
    
    func addBlurredImage(image: UIImage, toCacheWithURL url: NSURL, blurRadius: CGFloat) {
        SDWebImageManager.sharedManager().imageCache.storeImage(
            image,
            forKey: blurredImageKey(for: url, blurRadius: blurRadius)
        )
    }
    
    private func blurredImageKey(for url: NSURL, blurRadius: CGFloat) -> String {
        let imageExtension = "\(UIImageView.blurredImageCachePathExtension)/\(blurRadius)"
        return url.URLByAppendingPathComponent(imageExtension).absoluteString
    }
    
    private func blurImage(image: UIImage, withRadius radius: CGFloat, completion: ImageCompletion) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
            guard let blurredImage = image.applyBlur(withRadius: radius) else {
                completion?(nil, nil)
                return
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completion?(blurredImage, nil)
            }
        }
    }
    
    private func applyBlur(to image: UIImage, with url: NSURL? = nil, radius: CGFloat, completion: ImageCompletion) {
        guard let url = url else {
            // No URL to cache to, blur the image and call completion
            blurImage(image, withRadius: radius, completion: completion)
            return
        }
        
        // If we have the blurred image cached, return that copy
        if let cachedImage = cachedBlurredImage(for: url, blurRadius: radius) {
            completion?(cachedImage, nil)
            return
        }
        
        // Otherwise, blur the image and cache it
        blurImage(image, withRadius: radius) { [weak self] blurredImage, error in
            guard let blurredImage = blurredImage else {
                completion?(nil, error)
                return
            }
            
            self?.addBlurredImage(blurredImage, toCacheWithURL: url, blurRadius: radius)
            
            completion?(blurredImage, nil)
        }
    }
}
