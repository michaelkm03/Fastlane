//
//  VAsset+PersistenceParsable.swift
//  victorious
//
//  Created by Patrick Lynch on 12/14/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VAsset: PersistenceParsable {
    
    func populate( fromSourceModel asset: Asset ) {
        audioMuted              = asset.audioMuted ?? audioMuted
        backgroundColor         = asset.backgroundColor ?? backgroundColor
        backgroundImageUrl      = asset.backgroundImageUrl ?? backgroundImageUrl
        data                    = asset.data ?? data
        duration                = asset.duration ?? duration
        loop                    = asset.loop ?? loop
        mimeType                = asset.mimeType ?? mimeType
        playerControlsDisabled  = asset.playerControlsDisabled ?? playerControlsDisabled
        remoteContentId         = asset.remoteContentID ?? remoteContentId
        remoteId                = asset.assetID ?? remoteId
        remotePlayback          = asset.remotePlayback ?? remotePlayback
        remoteSource            = asset.remoteSource ?? remoteSource
        speed                   = asset.speed ?? speed
        streamAutoplay          = asset.streamAutoplay ?? streamAutoplay
        type                    = asset.type.rawValue ?? type
    }
    
    func populate( fromTextPostAsset asset: TextPostAsset) {
        type                    = asset.type.rawValue ?? type
        data                    = asset.data ?? data
        backgroundColor         = asset.backgroundColor ?? backgroundColor
        backgroundImageUrl      = asset.backgroundImageURL ?? backgroundImageUrl
    }
}
