//
//  StickerSearchResult.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

public struct StickerSearchResult {
    public let remoteID: String
    public let width: Int
    public let height: Int
    public let isVIP: Bool
    public let url: String
}

extension StickerSearchResult {
    public init?(json: JSON) {
        guard
            let remoteID = json["id"].string,
            let url = json["url"].string,
            let isVIP = json["is_vip"].bool
        else {
            return nil
        }
        
        //TODO: Once size is returned in stickers, put the following 2 lines (without the default values) back in the guard
        let width = json["size"]["width"].int ?? 100
        let height = json["size"]["height"].int ?? 100
        
        self.url = url
        self.remoteID = remoteID
        self.width = width
        self.height = height
        self.isVIP = isVIP
    }
}