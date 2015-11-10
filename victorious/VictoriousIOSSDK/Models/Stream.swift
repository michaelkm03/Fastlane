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
    public let name: String
    public let title: String?
    public let postCount: Int
    public let streamUrl: String?
    public let items: [StreamItemType]
    public let type: StreamContentType?
    public let subtype: StreamContentType?
    
    // MARK: - StreamItemType
    
    public let previewImagesObject: AnyObject?
    public let previewTextPostAsset: String?
    public let streamContentType: StreamContentType?
    public let previewImageAssets: [ImageAsset]
}

extension Stream {
    public init?(json: JSON) {
        guard let remoteID = json["id"].string else {
            return nil
        }
        self.remoteID           = remoteID
        
        name                    = json["name"].string ?? ""
        title                   = json["title"].string ?? ""
        postCount               = json["postCount"].int ?? 0
        streamUrl               = json["streamUrl"].string ?? ""
        
        items = ( json["items"].array ?? json["content"].array ?? []).flatMap {
            let isStream = $0["items"] != nil || $0["streamUrl"] != nil
            return isStream ? Stream(json: $0) : Sequence(json:$0)
        }
        
        // MARK: - StreamItemType
        
        previewTextPostAsset    = json["preview"].string
        previewImageAssets      = (json["preview.assets"].array ?? []).flatMap { ImageAsset(json: $0) }
        streamContentType       = StreamContentType( rawValue: json["stream_content_type"].string ?? "" )
        type                    = StreamContentType( rawValue: json["type"].string ?? "" )
        subtype                 = StreamContentType( rawValue: json["subtype"].string ?? "" )
        
        let previewImage = json["preview_image"]
        previewImagesObject = (previewImage.array?.flatMap { $0.string } as? AnyObject) ?? previewImage.string as? AnyObject
    }
}
