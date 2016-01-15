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
    let addTagURLString = "figure me out"

    func setupContentPlayer() -> Bool {
        guard let contentPlayheadIntstance = IMAAVPlayerContentPlayhead(AVPlayer: player) else {
            print("Failed to instantiate IMAAVPlayerContentPlayhead")
            return false
        }

        contentPlayhead = contentPlayheadIntstance
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "contentDidFinishPlaying:",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: player.currentItem)
        return true
    }

    func setupAdsLoader(delegate: IMAAdsLoaderDelegate) -> Bool {
        guard let adsLoader = IMAAdsLoader() else {
            print("Failed to instantiate IMAAdsLoader")
            return false
        }

        adsLoader.delegate = delegate
        return true
    }

    func contentDidFinishPlaying(notification: NSNotification) {
        guard let item = notification.object as? AVPlayerItem where item == player.currentItem else {
            return
        }
        adsLoader.contentComplete()
    }
}
