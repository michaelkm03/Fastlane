//
//  ImageSearchResult.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON

public struct ImageSearchResult {
    public let imageURL: NSURL
    public let thumbnailURL: NSURL
}

extension ImageSearchResult {
    public init?(json: JSON) {
        
        guard let imageURLString = json["url"].string,
            let thumbnailURLString = json["thumbnail"].string,
            let imageURL = NSURL(string: imageURLString),
            let thumbnailURL = NSURL(string: thumbnailURLString) else {
                return nil
        }
        
        self.imageURL = imageURL
        self.thumbnailURL = thumbnailURL
    }
}
