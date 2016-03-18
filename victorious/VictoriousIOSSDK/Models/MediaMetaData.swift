//
//  Stageable.swift
//  victorious
//
//  Created by Sebastian Nystorm on 10/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import CoreGraphics

public struct MediaMetaData {
    
    public let duration: Double?
    
    public let url: NSURL

    public let size: CGSize?
    
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
        
        if let width = json["width"].int, let height = json["height"].int {
            size = CGSize(width: width, height: height)
        } else {
            size = nil
        }
        
        // This is where the shared duration logics will go when we know what the backend will return.
        self.duration = json["duration"].double
    }
}
