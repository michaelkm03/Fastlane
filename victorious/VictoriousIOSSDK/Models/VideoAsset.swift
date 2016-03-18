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
    public let data: String
    public let size: CGSize?
    public let bitrate: Int?
    
    /// StartTime is used in order to sync viewers to the same spot in the video.
    public let startTime: Double
    
    // MARK: Stageable
    public let duration: Double?
    public let url: NSURL
    
    public init?(json: JSON) {
        guard let mimeType = json["mimeType"].string,
            let data = json["data"].string,
            let urlString = json["resourceLocation"].string,
            let url = NSURL(string: urlString),
            let startTime = json["start_time"].double
        else {
                print("Failed to create video asset. Error -> \(json["data"].error)")
                return nil
        }
        
        self.mimeType = VideoType(rawValue:mimeType)!
        self.data = data
        self.startTime = startTime
        
        if let width = json["width"].int, let height = json["height"].int {
            size = CGSize(width: width, height: height)
        } else {
            size = nil
        }

        bitrate = json["bitrate"].int
        
        // MARK: Stageable
        self.duration = json["duration"].double
        self.url = url
    }
}
