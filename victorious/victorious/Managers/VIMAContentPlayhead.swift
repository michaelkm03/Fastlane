//
//  VIMAContentPlayhead.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import GoogleInteractiveMediaAds

@objc class VIMAContentPlayhead: NSObject, IMAContentPlayhead {
    let player: VVideoPlayer

    init(player: VVideoPlayer) {
        self.player = player
    }

    @objc var currentTime: NSTimeInterval {
        return player.currentTimeSeconds
    }
}
