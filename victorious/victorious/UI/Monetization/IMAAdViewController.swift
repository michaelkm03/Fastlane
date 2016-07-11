//
//  IMAAdViewController.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import GoogleInteractiveMediaAds
import SafariServices
import AdSupport

private let adIDMacro = "%%ADID%%"

/// Provides an integration with Google IMA Ad system
@objc class IMAAdViewController: NSObject, VAdViewControllerType, IMAAdsLoaderDelegate, IMAAdsManagerDelegate, IMAWebOpenerDelegate {
    let adTag: String
    let player: VVideoPlayer
    let contentPlayhead: VIMAContentPlayhead
    let adsLoader: IMAAdsLoader
    let adView: UIView
    let adDetailViewController: UIViewController
    var adsManager: IMAAdsManager?
    weak var delegate: AdLifecycleDelegate?
    private var hasBeenCalled = false

    // MARK: - Initializers

    init(player: VVideoPlayer,
        adTag: String,
        adsLoader: IMAAdsLoader = IMAAdsLoader(),
        adView: UIView = UIView()) {
            self.player = player
            self.contentPlayhead = VIMAContentPlayhead(player: player)
            self.adView = adView
            self.adsLoader = adsLoader
            self.adDetailViewController = UIViewController()
            self.adDetailViewController.view = self.adView
            
            self.adTag = IMAAdViewController.replaceAdTagMacro(adTag)
            
            super.init()
            self.adsLoader.delegate = self
            NSNotificationCenter.defaultCenter().addObserver(
                self,
                selector: #selector(contentDidFinishPlaying(_: )),
                name: AVPlayerItemDidPlayToEndTimeNotification,
                object: player)
    }
    
    class func replaceAdTagMacro(adTag: String) -> String {
        let idfa: String = ASIdentifierManager.sharedManager().advertisingTrackingEnabled ? ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString : ""
        let newAdTag = VSDKURLMacroReplacement().urlByReplacingMacrosFromDictionary([
            adIDMacro: idfa
            ], inURLString: adTag)
        return newAdTag
    }

    // MARK: - VAdViewControllerType method overrides

    func startAdManager() {
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: adView, companionSlots: nil)
        let request = IMAAdsRequest(adTagUrl: adTag, adDisplayContainer: adDisplayContainer, contentPlayhead: contentPlayhead, userContext: nil)
        adsLoader.requestAdsWithRequest(request)
    }

    // MARK: - Notification handlers

    func contentDidFinishPlaying(notification: NSNotification) {
        if let player = notification.object as? VVideoPlayer where player === self.player {
            adsLoader.contentComplete()
        }
    }

    // MARK: - IMAAdsLoaderDelegate methods

    func adsLoader(loader: IMAAdsLoader!, adsLoadedWithData adsLoadedData: IMAAdsLoadedData!) {
        self.adsManager = adsLoadedData.adsManager
        guard let adsManagerInstance = self.adsManager else {
            v_log("Failed to instantiate IMAAdsManager, can't show ads without it")
            return
        }
        adsManagerInstance.delegate = self
        let adsRenderingSettings = IMAAdsRenderingSettings()
        adsRenderingSettings.webOpenerPresentingController = adDetailViewController
        adsRenderingSettings.webOpenerDelegate = self
        adsManagerInstance.initializeWithAdsRenderingSettings(adsRenderingSettings)
    }

    func adsLoader(loader: IMAAdsLoader!, failedWithErrorData adErrorData: IMAAdLoadingErrorData!) {
        let imaError = adErrorData.adError
        v_log("Failed to load ads with error: \(imaError.message)")
        let error = NSError(domain: kVictoriousErrorDomain,
            code: imaError.code.rawValue,
            userInfo: [kVictoriousErrorMessageKey: imaError.message])
        delegate?.adHadError(error)
    }

    // MARK: - IMAAdsManagerDelegate methods

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
        case .COMPLETE:
            callOnce() {
                self.delegate?.adDidFinish()
            }
        case .ALL_ADS_COMPLETED:
            callOnce {
                self.delegate?.adDidFinish()
            }
        case .FIRST_QUARTILE:
            break
        case .LOADED:
            if event.ad != nil {
                adsManager.start()
                delegate?.adDidLoad()
            }
        case .MIDPOINT:
            break
        case .PAUSE:
            break
        case .RESUME:
            break
        case .SKIPPED:
            delegate?.adDidFinish()
        case .STARTED:
            delegate?.adDidStart()
        case .TAPPED:
            break
        case .THIRD_QUARTILE:
            break
        }
    }

    func adsManager(adsManager: IMAAdsManager!, didReceiveAdError error: IMAAdError!) {
        v_log("IMAAdsManager has an error: \(error.message)")
        let nsError = NSError(domain: kVictoriousErrorDomain,
            code: error.code.rawValue,
            userInfo: [kVictoriousErrorMessageKey: error.message])
        delegate?.adHadError(nsError)
    }

    func adsManagerDidRequestContentPause(adsManager: IMAAdsManager!) {
        player.pause()
    }

    func adsManagerDidRequestContentResume(adsManager: IMAAdsManager!) {
        player.play()
    }

    // MARK: - IMAWebOpenerDelegate

    func webOpenerDidCloseInAppBrowser(webOpener: NSObject) {
        delegate?.adDidFinish()
    }

    private func callOnce(block: () -> Void) {
        if hasBeenCalled == true {
            return
        }
        hasBeenCalled = true
        block()
    }
}
