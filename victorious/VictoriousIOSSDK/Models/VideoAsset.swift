//
//  VideoAsset.swift
//  victorious
//
//  Created by Sebastian Nystorm on 9/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct VideoAsset: Stageable {

    public enum VideoType: String {
        case HLS
        case MP4
    }
    
    public let mimeType: VideoType
    public let data: String
    public let size: CGSize?
    public let bitrate: Int?
    
    // MARK: Stageable
    public let duration: Double?
    public let endTime: Double?
    public let resourceLocation: String?
    
    
    public init?(json: JSON) {
        guard let mimeType = json["mimeType"].string else {
                print("Failed to create video asset. Error -> \(json["mimeType"].error)")
                return nil
        }
        
        guard let data = json["data"].string else {
                print("Failed to create video asset. Error -> \(json["data"].error)")
                return nil
        }
        
        self.mimeType = VideoType(rawValue:mimeType)!
        self.data = data
        
        if let width = json["width"].int, let height = json["height"].int {
            size = CGSize(width: width, height: height)
        } else {
            size = nil
        }

        bitrate = json["bitrate"].int
        
        // MARK: Stageable
        duration = json["duration"].double
        endTime = json["endTime"].double
        resourceLocation = json["resourceLocation"].string
    }
}
