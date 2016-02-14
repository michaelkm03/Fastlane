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
@objc class IMAAdViewController: NSObject, VAdViewControllerType, IMAAdsLoaderDelegate, IMAAdsManagerDelegate, IMAWebOpenerDelegate {
    let adTag: String
    let player: VVideoPlayer
    let contentPlayhead: VIMAContentPlayhead
    let adsLoader: IMAAdsLoader
    let adView: UIView
    let adDetailViewController: UIViewController
    var adsManager: IMAAdsManager?
    var delegate: AdLifecycleDelegate?

    //MARK: - Initializers

    init(player: VVideoPlayer,
        adTag: String,
        adsLoader: IMAAdsLoader = IMAAdsLoader(),
        adView: UIView = UIView()) {
            self.adTag = adTag
            self.player = player
            self.contentPlayhead = VIMAContentPlayhead(player: player)
            self.adView = adView
            self.adsLoader = adsLoader
            self.adDetailViewController = UIViewController()
            self.adDetailViewController.view = self.adView
            super.init()
            self.adsLoader.delegate = self
            NSNotificationCenter.defaultCenter().addObserver(
                self,
                selector: "contentDidFinishPlaying:",
                name: AVPlayerItemDidPlayToEndTimeNotification,
                object: player)
    }

    //MARK: - VAdViewControllerType method overrides

    func startAdManager() {
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: adView, companionSlots: nil)
        let request = IMAAdsRequest(adTagUrl: adTag, adDisplayContainer: adDisplayContainer, contentPlayhead: contentPlayhead, userContext: nil)
        adsLoader.requestAdsWithRequest(request)
    }

    //MARK: - Notification handlers

    func contentDidFinishPlaying(notification: NSNotification) {
        if let player = notification.object as? VVideoPlayer where player === self.player {
            adsLoader.contentComplete()
        }
    }

    //MARK: - IMAAdsLoaderDelegate methods

    func adsLoader(loader: IMAAdsLoader!, adsLoadedWithData adsLoadedData: IMAAdsLoadedData!) {
        self.adsManager = adsLoadedData.adsManager
        guard let adsManagerInstance = self.adsManager else {
            VLog("Failed to instantiate IMAAdsManager, can't show ads without it")
            return
        }
        adsManagerInstance.delegate = self
        let adsRenderingSettings = IMAAdsRenderingSettings()
        adsRenderingSettings.webOpenerPresentingController = adDetailViewController
        adsRenderingSettings.webOpenerDelegate = self
        adsManagerInstance.initializeWithAdsRenderingSettings(adsRenderingSettings)
        delegate?.adDidLoad()
    }

    func adsLoader(loader: IMAAdsLoader!, failedWithErrorData adErrorData: IMAAdLoadingErrorData!) {
        let imaError = adErrorData.adError
        VLog("Failed to load ads with error: \(imaError.message)")
        let error = NSError(domain: kVictoriousErrorDomain,
            code: imaError.code.rawValue,
            userInfo: [kVictoriousErrorMessageKey : imaError.message])
        delegate?.adHadError(error)
    }

    //MARK: - IMAAdsManagerDelegate methods

    func adsManager(adsManager: IMAAdsManager!, didReceiveAdEvent event: IMAAdEvent!) {
        switch event.type {
        case .AD_BREAK_READY:
            break
        case .AD_BREAK_ENDED:
            break
        case .AD_BREAK_STARTED:
            break
        case .CLICKED:
            adsManager.discardAdBreak()
        case .COMPLETE, .ALL_ADS_COMPLETED:
            delegate?.adDidFinish()
        case .FIRST_QUARTILE:
            delegate?.adDidHitFirstQuartile?()
        case .LOADED:
            adsManager.start()
            delegate?.adDidLoad()
        case .MIDPOINT:
            delegate?.adDidHitMidpoint?()
        case .PAUSE:
            break
        case .RESUME:
            break
        case .SKIPPED:
            delegate?.adDidFinish()
        case .STARTED:
            delegate?.adDidStart()
        case .TAPPED:
            delegate?.adHadImpression?()
        case .THIRD_QUARTILE:
            delegate?.adDidHitThirdQuartile?()
        }
    }

    func adsManager(adsManager: IMAAdsManager!, didReceiveAdError error: IMAAdError!) {
        VLog("IMAAdsManager has an error: \(error.message)")
        let nsError = NSError(domain: kVictoriousErrorDomain,
            code: error.code.rawValue,
            userInfo: [kVictoriousErrorMessageKey : error.message])
        delegate?.adHadError(nsError)
    }

    func adsManagerDidRequestContentPause(adsManager: IMAAdsManager!) {
        player.pause()
    }

    func adsManagerDidRequestContentResume(adsManager: IMAAdsManager!) {
        player.play()
    }

    //MARK: - IMAWebOpenerDelegate

    func webOpenerDidCloseInAppBrowser(webOpener: NSObject) {
        delegate?.adDidFinish()
    }
}
