//
//  ImageSearchResult.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

public struct ImageSearchResult {
    public let imageURL: NSURL
    public let thumbnailURL: NSURL
}

extension ImageSearchResult {
    
    public init?(json: JSON) {
        guard let imageURL = NSURL(vsdk_string: json["url"].string),
            let thumbnailURL = NSURL(vsdk_string: json["thumbnail"].string) else {
                return nil
        }
        
        self.imageURL = imageURL
        self.thumbnailURL = thumbnailURL
    }
}
