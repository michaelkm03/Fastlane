//
//  Asset.swift
//  victorious
//
//  Created by Patrick Lynch on 11/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum AssetType: String {
    case Media  = "media"
    case Path   = "path"
    case Text   = "text"
    case URL    = "url"
}

public struct Asset {
    public let assetID: Int
    public let audioMuted: Bool?
    public let backgroundColor: String?
    public let backgroundImageUrl: String?
    public let data: String
    public let duration: Double?
    public let loop: Bool?
    public let mimeType: String?
    public let playerControlsDisabled: Bool?
    public let remoteContentID: String?
    public let remotePlayback: Bool?
    public let remoteSource: String?
    public let speed: Double?
    public let streamAutoplay: Bool?
    public let type: AssetType
}

extension Asset {
    public init?(json: JSON) {
        guard let assetID = Int(json["asset_id"].string ?? ""),
            let type = AssetType(rawValue: json["type"].string ?? ""),
            let data = json["data"].string else {
                return nil
        }
        self.type               = type
        self.data               = data
        self.assetID            = assetID
        
        audioMuted              = json["audio_muted"].v_boolFromAnyValue
        backgroundColor         = json["background_color"].string
        backgroundImageUrl      = json["background_image"].string
        duration                = json["duration"].double
        loop                    = json["loop"].v_boolFromAnyValue
        mimeType                = json["mime_type"].string
        playerControlsDisabled  = json["player_controls_disabled"].bool
        remoteContentID         = json["remote_content_id"].string
        remotePlayback          = json["remote_playback"].v_boolFromAnyValue
        remoteSource            = json["remote_source"].string
        speed                   = json["speed"].double
        streamAutoplay          = json["stream_autoplay"].v_boolFromAnyValue
    }
}
