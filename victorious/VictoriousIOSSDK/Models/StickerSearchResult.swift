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
            let isVIP = json["is_vip"].bool,
            let width = json["width"].int,
            let height = json["height"].int
        else {
            return nil
        }

        self.url = url
        self.remoteID = remoteID
        self.width = width
        self.height = height
        self.isVIP = isVIP
    }
}
