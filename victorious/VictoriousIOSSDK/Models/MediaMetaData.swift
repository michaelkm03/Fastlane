//
//  MediaMetaData.swift
//  victorious
//
//  Created by Sebastian Nystorm on 10/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import CoreGraphics

public struct MediaMetaData {

    public let url: NSURL

    public let size: CGSize
    
    /// The data container that describes the meta data related to the media on the stage.
    /// 
    /// - parameter json: JSON to be parsed into the component.
    /// - parameter customUrlKeys: A list of keys for parsing out the url from the fragmented JSON response.
    /// - returns: A `MediaMetaData` struct is returned. Initialization can fail if no URL is found in the JSON.
    public init?(json: JSON, customUrlKeys: [String] = ["data"]) {
        var foundUrl: NSURL?
        for urlKey in customUrlKeys {
            if let urlString = json[urlKey].string, let url = NSURL(string: urlString) {
                foundUrl = url
                break
            }
        }
        
        guard let url = foundUrl else {
            return nil
        }
        
        self.url = url
        
        guard let width = json["width"].int, let height = json["height"].int else {
            return nil
        }
        self.size = CGSize(width: width, height: height)
    }
    
    public init(url: NSURL, size: CGSize) {
        self.url = url
        self.size = size
    }
}
