//
//  VAsset+PersistenceParsable.swift
//  victorious
//
//  Created by Patrick Lynch on 11/6/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VAsset: PersistenceParsable {
    
    func populate( fromSourceModel asset: Asset ) {
        audioMuted              = asset.audioMuted
        backgroundColor         = asset.backgroundColor
        backgroundImageUrl      = asset.backgroundImageUrl
        data                    = asset.data
        duration                = asset.duration
        loop                    = asset.loop
        mimeType                = asset.mimeType
        playerControlsDisabled  = asset.playerControlsDisabled
        remoteContentId         = asset.remoteContentID
        remoteId                = Int(asset.assetID)
        remotePlayback          = asset.remotePlayback
        remoteSource            = asset.remoteSource
        speed                   = asset.speed
        streamAutoplay          = asset.streamAutoplay
        type                    = asset.type.rawValue
    }
}
