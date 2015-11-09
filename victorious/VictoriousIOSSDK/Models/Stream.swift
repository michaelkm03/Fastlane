//
//  Stream.swift
//  victorious
//
//  Created by Patrick Lynch on 11/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Stream: StreamItemType {
    public let remoteID: String
    public let type: String
    public let subtype: String
    public let name: String
    public let title: String?
    public let postCount: Int
    public let streamUrl: String?
    public let items: [StreamItemType]
    
    // MARK: - StreamItemType
    
    public let previewImagesObject: AnyObject?
    public let previewTextPostAsset: String?
    public let streamContentType: StreamContentType?
    public let itemType: StreamContentType?
    public let itemSubType: StreamContentType?
    public let previewImageAssets: [ImageAsset]
    public let streams: [Stream]
}

extension Stream {
    public init?(json: JSON) {
        guard let remoteID = json["id"].string else {
            return nil
        }
        self.remoteID           = remoteID
        
        type                    = json["type"].string ?? ""
        subtype                 = json["subtype"].string ?? ""
        name                    = json["name"].string ?? ""
        title                   = json["title"].string ?? ""
        postCount               = json["postCount"].int ?? 0
        streamUrl               = json["streamUrl"].string ?? ""
        
        items = (json["items"].array ?? json["content"].array ?? []).flatMap {
            let isStream = json["items" ] != nil || json["streamUrl"] != nil
            return isStream ? Stream(json: $0) : Sequence(json:$0)
        }
        
        // MARK: - StreamItemType
        
        previewImagesObject     = json["preview_image"].object
        previewTextPostAsset    = json["preview"].string
        previewImageAssets      = (json["preview.assets"].array ?? []).flatMap { ImageAsset(json: $0) }
        streams                 = (json["streams"].array ?? []).flatMap { Stream(json: $0) }
        streamContentType       = StreamContentType( rawValue: json["stream_content_type"].string ?? "" )
        itemType                = StreamContentType( rawValue: json["type"].string ?? "" )
        itemSubType             = StreamContentType( rawValue: json["subtype"].string ?? "" )
    }
}
