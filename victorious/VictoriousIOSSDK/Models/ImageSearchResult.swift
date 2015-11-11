//
//  ImageSearchResult.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON

public struct ImageSearchResult {
    public let imageURL: String
    public let thumbnailURL: String
}

extension ImageSearchResult {
    public init?(json: JSON) {
        
        guard let imageURLString = json["url"].string,
            let thumbnailURLString = json["thumbnail"].string else {
                return nil
        }
        
        imageURL = imageURLString
        thumbnailURL = thumbnailURLString
    }
}
