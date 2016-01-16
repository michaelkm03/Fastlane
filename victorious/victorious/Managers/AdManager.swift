//
//  AdManager.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import AVFoundation
import GoogleInteractiveMediaAds

@objc class AdManager: NSObject, IMAAdsLoaderDelegate {
    let player: AVPlayer
    let contentPlayhead: IMAAVPlayerContentPlayhead
    let adsLoader: IMAAdsLoader
    let videoView: UIView

    init(player: AVPlayer, videoView: UIView) {
        self.player = player
        self.contentPlayhead = IMAAVPlayerContentPlayhead(AVPlayer: player)
        self.adsLoader = IMAAdsLoader()
        self.videoView = videoView
        super.init()

        self.adsLoader.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "contentDidFinishPlaying:",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: player.currentItem)
    }

    func requestAds(adTagURLString: String) {
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: videoView, companionSlots: nil)
        let request = IMAAdsRequest(adTagUrl: adTagURLString, adDisplayContainer: adDisplayContainer, contentPlayhead: contentPlayhead, userContext: nil)
        adsLoader.requestAdsWithRequest(request)
    }

    func contentDidFinishPlaying(notification: NSNotification) {
        if let playerItem = notification.object as? AVPlayerItem where playerItem == player.currentItem {
            adsLoader.contentComplete()
        }
    }

    func adsLoader(loader: IMAAdsLoader!, adsLoadedWithData adsLoadedData: IMAAdsLoadedData!) {
    }

    func adsLoader(loader: IMAAdsLoader!, failedWithErrorData adErrorData: IMAAdLoadingErrorData!) {
    }
}
