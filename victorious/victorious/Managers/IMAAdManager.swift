//
//  IMAAdManager.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import AVFoundation
import GoogleInteractiveMediaAds

@objc class IMAAdManager: NSObject, IMAAdsLoaderDelegate, IMAAdsManagerDelegate {
    let player: AVPlayer
    let contentPlayhead: IMAAVPlayerContentPlayhead
    let adsLoader: IMAAdsLoader

    init(player: AVPlayer) {
        self.player = player
        self.contentPlayhead = IMAAVPlayerContentPlayhead(AVPlayer: player)
        self.adsLoader = IMAAdsLoader()
        super.init()

        self.adsLoader.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "contentDidFinishPlaying:",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: player.currentItem)
    }

    func requestAds(adTag adTag: String, adContainerView: UIView) {
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: adContainerView, companionSlots: nil)
        let request = IMAAdsRequest(adTagUrl: adTag, adDisplayContainer: adDisplayContainer, contentPlayhead: contentPlayhead, userContext: nil)
        adsLoader.requestAdsWithRequest(request)
    }

    func contentDidFinishPlaying(notification: NSNotification) {
        if let playerItem = notification.object as? AVPlayerItem where playerItem == player.currentItem {
            adsLoader.contentComplete()
        }
    }

    // MARK - IMAAdsLoaderDelegate methods

    func adsLoader(loader: IMAAdsLoader!, adsLoadedWithData adsLoadedData: IMAAdsLoadedData!) {
        let adsManager = adsLoadedData.adsManager
        adsManager.delegate = self
        let adsRenderingSettings = IMAAdsRenderingSettings()
        adsRenderingSettings.webOpenerPresentingController = UIViewController()
        adsManager.initializeWithAdsRenderingSettings(adsRenderingSettings)
    }

    func adsLoader(loader: IMAAdsLoader!, failedWithErrorData adErrorData: IMAAdLoadingErrorData!) {
        print("Failed to load adds with error: \(adErrorData.adError.message)")
        player.play()
    }

    // MARK - IMAAdsManagerDelegate methods

    func adsManager(adsManager: IMAAdsManager!, didReceiveAdEvent event: IMAAdEvent!) {
        if event.type == IMAAdEventType.LOADED {
            adsManager.start()
        }
    }

    func adsManager(adsManager: IMAAdsManager!, didReceiveAdError error: IMAAdError!) {
        print("IMAAdsManager has an error: \(error.message)")
        player.play()
    }

    func adsManagerDidRequestContentPause(adsManager: IMAAdsManager!) {
        player.pause()
    }

    func adsManagerDidRequestContentResume(adsManager: IMAAdsManager!) {
        player.play()
    }
}
