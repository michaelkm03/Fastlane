//
//  IMAAdViewController.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import GoogleInteractiveMediaAds
import SafariServices

/// Provides an integration with Google IMA Ad system
@objc class IMAAdViewController: VAdViewController, IMAAdsLoaderDelegate, IMAAdsManagerDelegate {
    let adTag: String
    let player: VVideoPlayer
    let contentPlayhead: VIMAContentPlayhead
    let adsLoader: IMAAdsLoader
    var adsManager: IMAAdsManager?

    init(player: VVideoPlayer, adTag: String, nibName: String? = nil, nibBundle: NSBundle? = nil) {
        self.adTag = adTag
        self.player = player
        self.contentPlayhead = VIMAContentPlayhead(player: player)
        self.adsLoader = IMAAdsLoader()
        super.init(nibName: nibName, bundle: nibBundle)

        self.adsLoader.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "contentDidFinishPlaying:",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: player)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func startAdManager() {
        guard let view = self.view else {
            print("Can't play ads on a non existent view")
            return
        }
        requestAds(adTag: adTag, adContainerView: view)
    }

    private func requestAds(adTag adTag: String, adContainerView: UIView) {
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: adContainerView, companionSlots: nil)
        let request = IMAAdsRequest(adTagUrl: adTag, adDisplayContainer: adDisplayContainer, contentPlayhead: contentPlayhead, userContext: nil)
        adsLoader.requestAdsWithRequest(request)
    }

    func contentDidFinishPlaying(notification: NSNotification) {
        if let player = notification.object as? VVideoPlayer where player === self.player {
            adsLoader.contentComplete()
        }
    }

    //MARK: - IMAAdsLoaderDelegate methods

    func adsLoader(loader: IMAAdsLoader!, adsLoadedWithData adsLoadedData: IMAAdsLoadedData!) {
        self.adsManager = adsLoadedData.adsManager
        guard let adsManagerInstance = self.adsManager else {
            print("Failed to instantiate IMAAdsManager, can't show ads without it")
            return
        }
        adsManagerInstance.delegate = self
        let adsRenderingSettings = IMAAdsRenderingSettings()
        adsRenderingSettings.webOpenerPresentingController = self
        adsManagerInstance.initializeWithAdsRenderingSettings(adsRenderingSettings)
    }

    func adsLoader(loader: IMAAdsLoader!, failedWithErrorData adErrorData: IMAAdLoadingErrorData!) {
        let imaError = adErrorData.adError
        let error = NSError(domain: kVictoriousErrorDomain,
            code: imaError.code.rawValue,
            userInfo: [kVictoriousErrorMessageKey : imaError.message])
        delegate?.adHadErrorInAdViewController?(self, withError: error)
    }

    //MARK: - IMAAdsManagerDelegate methods

    func adsManager(adsManager: IMAAdsManager!, didReceiveAdEvent event: IMAAdEvent!) {
        switch event.type {
        case .AD_BREAK_READY: break
        case .AD_BREAK_ENDED: break
        case .AD_BREAK_STARTED: break
        case .CLICKED: break
        case .COMPLETE, .ALL_ADS_COMPLETED: delegate?.adDidFinishForAdViewController(self)
        case .FIRST_QUARTILE: delegate?.adDidHitFirstQuartileInAdViewController?(self)
        case .LOADED:
            adsManager.start()
            delegate?.adDidLoadForAdViewController(self)
        case .MIDPOINT: delegate?.adDidHitMidpointInAdViewController?(self)
        case .PAUSE: break
        case .RESUME:
            adsManager.pause()
            delegate?.adDidStopPlaybackInAdViewController?(self)
        case .SKIPPED: delegate?.adDidFinishForAdViewController(self)
        case .STARTED: delegate?.adDidStartPlaybackInAdViewController?(self)
        case .TAPPED: delegate?.adHadImpressionInAdViewController?(self)
        case .THIRD_QUARTILE: delegate?.adDidHitThirdQuartileInAdViewController?(self)
        }
    }

    func adsManager(adsManager: IMAAdsManager!, didReceiveAdError error: IMAAdError!) {
        print("IMAAdsManager has an error: \(error.message)")
        let nsError = NSError(domain: kVictoriousErrorDomain,
            code: error.code.rawValue,
            userInfo: [kVictoriousErrorMessageKey : error.message])
        delegate?.adHadErrorInAdViewController?(self, withError: nsError)
    }

    func adsManagerDidRequestContentPause(adsManager: IMAAdsManager!) {
    }

    func adsManagerDidRequestContentResume(adsManager: IMAAdsManager!) {
    }
}
