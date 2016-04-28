//
//  VideoAsset.swift
//  victorious
//
//  Created by Sebastian Nystorm on 9/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

public struct VideoAsset {

    public enum VideoType: String {
        case HLS = "HLS"
        case MP4 = "MP4"
    }
    
    public let mimeType: VideoType
    public let bitrate: Int?
    
    /// `startTime` is used in order to sync viewers to the same spot in the video, defaults to 0.0.
    public let startTime: NSTimeInterval
    
    public let mediaMetaData: MediaMetaData
    
    public init?(json: JSON) {
        guard let mimeType = json["mimeType"].string else {
                return nil
        }

        self.mimeType = VideoType(rawValue:mimeType)!
        self.startTime = json["start_time"].double ?? 0.0

        bitrate = json["bitrate"].int

        // MARK: Stageable
        guard let mediaMetaData = MediaMetaData(json: json, customUrlKeys: ["resourceLocation"]) else {
            return nil
        }
        self.mediaMetaData = mediaMetaData
    }
}
