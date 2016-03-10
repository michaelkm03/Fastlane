//
//  VideoAsset.swift
//  victorious
//
//  Created by Sebastian Nystorm on 9/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

struct VideoAsset {

    enum VideoType: String {
        case HLS
        case MP4
    }
    
    let mimeType: VideoType
    let data: String
    let height: Int?
    let width: Int?
    let bitrate: Int?
    
    public init?(json: JSON) {
        guard let mimeType = json["mimeType"].string,
            data = json["data"].string else {
                print("Failed to create video asset")
               return nil
        }
        self.mimeType = VideoType(rawValue:mimeType)
        self.data = data
        
        height = json["height"].int
        width = json["width"].int
        bitrate = json["bitrate"].int
        
//        guard let messageID = Int(json["message_id"].stringValue),
//            let postedAt = NSDateFormatter.vsdk_defaultDateFormatter().dateFromString(json["posted_at"].stringValue) else {
//                return nil
//        }
//        self.messageID          = messageID
//        self.postedAt           = postedAt
//        
//        self.sender             = User(json: json["sender_user"])
//        self.isRead             = json["is_read"].v_boolFromAnyValue
//        self.text               = json["text"].string
//        self.mediaAttachment    = MediaAttachment(json: json)
    }
}
