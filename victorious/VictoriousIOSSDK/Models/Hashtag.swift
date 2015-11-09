//
//  Hashtag.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON

public struct Hashtag {
    public let hashtagID: Int64
    public let tag: String
    public let amFollowing: Bool?
    public let count: Int?
}

extension Hashtag {
    public init?(json: JSON) {
        
        if let hashtagIDString = json["id"].string,
            let hashtagIDNumber = Int64(hashtagIDString) {
                hashtagID = hashtagIDNumber
        } else {
            return nil
        }
        
        if let tagString = json["tag"].string {
            tag = tagString
        } else {
            return nil
        }
        
        amFollowing = json["am_following"].bool
        count = json["count"].int ?? Int(json["count"].stringValue)
    }
}
