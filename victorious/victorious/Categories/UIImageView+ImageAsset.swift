//
//  UIImageView+ImageAsset.swift
//  victorious
//
//  Created by Tian Lan on 7/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import SDWebImage

typealias ImageCompletion = ((Result<UIImage>) -> Void)?

extension UIImageView {
    fileprivate static let blurredImageCachePathExtension = "blurred"
    
    /// Downloads the image from the image asset or grabs the cached version to return in the completion block
    func getImageAsset(_ imageAsset: ImageAssetModel, blurRadius: CGFloat = 0, completion: ImageCompletion) {
        image = nil
        
        let imageBlurBlock: (UIImage?, URL?, NSError?) -> Void = { [weak self] image, url, error in
            guard let image = image else {
                completion?(.failure(error))
                return
            }
            
            if blurRadius != 0 {
                self?.applyBlur(to: image, with: url, radius: blurRadius, completion: completion)
            }
            else {
                completion?(.success(image))
            }
        }
        
        switch imageAsset.imageSource {
            case .remote(let url):
                sd_setImageWithURL(
                    url as URL!,
                    placeholderImage: image,
                    options: .AvoidAutoSetImage
                ) { image, error, _, url in
                    imageBlurBlock(image, url, error)
                }
            case .local(let image):
                imageBlurBlock(image, nil, nil)
        }
    }
    
    fileprivate func cachedBlurredImage(for url: URL, blurRadius: CGFloat) -> UIImage? {
        let key = blurredImageKey(for: url, blurRadius: blurRadius)
        return SDWebImageManager.shared().imageCache.imageFromMemoryCache(forKey: key)
    }
    
    fileprivate func addBlurredImage(_ image: UIImage, toCacheWithURL url: URL, blurRadius: CGFloat) {
        guard let key = blurredImageKey(for: url, blurRadius: blurRadius) else {
            return
        }
        
        SDWebImageManager.shared().imageCache.store(
            image,
            forKey: key
        )
    }
    
    fileprivate func blurredImageKey(for url: URL, blurRadius: CGFloat) -> String? {
        let imageExtension = "\(UIImageView.blurredImageCachePathExtension)/\(blurRadius)"
        let key = url.appendingPathComponent(imageExtension).absoluteString
        return key
    }
    
    fileprivate func blurImage(_ image: UIImage, withRadius radius: CGFloat, completion: ImageCompletion) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            guard let blurredImage = image.applyBlur(withRadius: radius) else {
                completion?(.failure(nil))
                return
            }
            
            DispatchQueue.main.async {
                completion?(.success(blurredImage))
            }
        }
    }
    
    fileprivate func applyBlur(to image: UIImage, with url: URL? = nil, radius: CGFloat, completion: ImageCompletion) {
        guard let url = url else {
            // No URL to cache to, blur the image and call completion
            blurImage(image, withRadius: radius, completion: completion)
            return
        }
        
        // If we have the blurred image cached, return that copy
        if let cachedImage = cachedBlurredImage(for: url, blurRadius: radius) {
            completion?(.success(cachedImage))
            return
        }
        
        // Otherwise, blur the image and cache it
        blurImage(image, withRadius: radius) { [weak self] result in
            switch result {
                case .success(let blurredImage):
                    self?.addBlurredImage(blurredImage, toCacheWithURL: url, blurRadius: radius)
                    completion?(.success(blurredImage))

                case .failure(let error):
                    completion?(.failure(error))
            }
        }
    }
}
