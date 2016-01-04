//
//  Hashtag.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON

public struct Hashtag {
    public let tag: String
    public let amFollowing: Bool?
    public let count: Int64?
}

extension Hashtag {
    public init?(json: JSON) {
        if let tag = json["tag"].string {
            self.tag = tag
        } else {
            return nil
        }
        
        amFollowing = json["am_following"].bool
        count = Int64(json["count"].stringValue) ?? json["count"].int64
    }
}
