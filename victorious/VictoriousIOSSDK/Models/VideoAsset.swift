//
//  VideoAsset.swift
//  victorious
//
//  Created by Sebastian Nystorm on 9/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import CoreGraphics

public struct VideoAsset: Stageable {

    public enum VideoType: String {
        case HLS
        case MP4
    }
    
    public let mimeType: VideoType
    public let bitrate: Int?
    
    /// StartTime is used in order to sync viewers to the same spot in the video.
    public let startTime: Double
    
    // MARK: Stageable
    public let mediaMetaData: MediaMetaData
    
    public init?(json: JSON) {
        guard let mimeType = json["mimeType"].string,
            let startTime = json["start_time"].double else {
                return nil
        }
        
        self.mimeType = VideoType(rawValue:mimeType)!
        self.startTime = startTime

        bitrate = json["bitrate"].int
        
        // MARK: Stageable
        guard let mediaMetaData = MediaMetaData(json: json, customUrlKeys: ["resourceLocation"]) else {
            return nil
        }
        self.mediaMetaData = mediaMetaData
    }
}
