//
//  VVideoView.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import AVFoundation
import GoogleInteractiveMediaAds

extension VVideoView {
    func setupContentPlayer(player player: AVPlayer) -> IMAAVPlayerContentPlayhead {
        return IMAAVPlayerContentPlayhead(AVPlayer: player)
    }
}
