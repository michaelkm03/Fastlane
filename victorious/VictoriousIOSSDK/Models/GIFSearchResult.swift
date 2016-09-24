//
//  GIFSearchResult.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

public struct GIFSearchResult {
    public let gifURL: String
    public let gifSize: Int?
    public let mp4URL: String
    public let mp4Size: Int?
    public let frames: Int?
    public let width: Int
    public let height: Int
    public let thumbnailURL: String?
    public let thumbnailStillURL: String
    public let remoteID: String
}

extension GIFSearchResult {
    public init?(json: JSON) {
        guard let gifURLString = json["gif_url"].string,
            let mp4URLString = json["mp4_url"].string,
            let widthNumber = json["width"].int,
            let heightNumber = json["height"].int,
            let thumbnailStillURLString = json["thumbnail_still"].string,
            let remoteIDString = json["remote_id"].string else {
                return nil
        }
        
        gifURL = gifURLString
        mp4URL = mp4URLString
        width = widthNumber
        height = heightNumber
        thumbnailStillURL = thumbnailStillURLString
        remoteID = remoteIDString
        gifSize = json["gif_size"].int
        mp4Size = json["mp4_size"].int
        frames = json["frames"].int
        thumbnailURL = json["thumbnail"].string
    }
}
