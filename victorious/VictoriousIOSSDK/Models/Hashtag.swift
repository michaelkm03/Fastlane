//
//  Hashtag.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

public struct Hashtag {
    public let tag: String
    
    public init( tag: String ) {
        self.tag = tag
    }
}

extension Hashtag {
    public init?(json: JSON) {
        guard let tag = json["hashtag"].string else {
            return nil
        }
        self.tag = tag
    }
}
