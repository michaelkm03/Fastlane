//
//  GifAsset.swift
//  victorious
//
//  Created by Sebastian Nystorm on 14/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct GifAsset: Stageable {

    public let size: CGSize?
    public let thumbnailURL: String?

    // MARK: Stageable
    public let duration: Double?
    public let url: NSURL
}


extension GifAsset {
    public init?(json: JSON) {
        guard let urlString = json["url"].string,
            let url = NSURL(string: urlString) else {
                return nil
        }
        self.url = url
        
        if let width = json["width"].int, let height = json["height"].int {
            size = CGSize(width: width, height: height)
        } else {
            size = nil
        }
        
        thumbnailURL = json["thumbnail_url"].string
        
        // MARK: Stageable
        self.duration = json["duration"].double
    }
}
