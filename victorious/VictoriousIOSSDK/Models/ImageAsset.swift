//
//  ImageAsset.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/25/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import UIKit
import CoreGraphics

/// Conformers are models that store information about an image asset
/// Consumers can directly use this type without caring what the concrete type is, persistent or not.
public protocol ImageAssetModel {
    var imageSource: ImageSource { get }
    var size: CGSize { get }
}

public extension ImageAssetModel {
    var url: NSURL? {
        switch imageSource {
            case .remote(let url): return url
            case .local: return nil
        }
    }
    
    var localImage: UIImage? {
        switch imageSource {
            case .remote: return nil
            case .local(let image): return image
        }
    }
}

/// A thumbnail, profile picture, or other image asset
public struct ImageAsset: ImageAssetModel {
    public let imageSource: ImageSource
    public let size: CGSize
    
    ///
    /// - parameter json: JSON to be parsed into the component.
    /// - parameter customUrlKeys: A list of keys for parsing out the url from the fragmented JSON response.
    ///
    public init?(json: JSON, customURLKeys: [String] = ["imageUrl", "image_url", "imageURL"]) {
        var foundUrl: NSURL?
        for urlKey in customURLKeys {
            if let urlString = json[urlKey].string, let url = NSURL(string: urlString) {
                foundUrl = url
                break
            }
        }
        
        guard let url = foundUrl else {
            return nil
        }
        
        self.imageSource = .remote(url: url)
        
        guard let width = json["width"].int, let height = json["height"].int else {
            return nil
        }
        self.size = CGSize(width: width, height: height)
    }
    
    public init(url: NSURL, size: CGSize) {
        self.imageSource = .remote(url: url)
        self.size = size
    }
    
    public init(image: UIImage) {
        self.imageSource = .local(image: image)
        self.size = image.size
    }
}

/// An enum that represents a local image or remote image
public enum ImageSource {
    case remote(url: NSURL)
    case local(image: UIImage)
}
