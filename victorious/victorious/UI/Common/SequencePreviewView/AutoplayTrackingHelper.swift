//
//  AutoplayTrackingHelper.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension VNetworkStatus {
    var trackingDescription : String {
        switch (self) {
        case .NotReachable:
            return "unknown"
        case .ReachableViaWiFi:
            return "wifi"
        case .ReachableViaWWAN:
            return "3g"
        }
    }
}

class AutoplayTrackingHelper : NSObject {
    
    var trackingItem: VTracking?
    private let reachability = VReachability.reachabilityForInternetConnection()
    private let trackingManager = VTrackingManager.sharedInstance()
    
    var infoParameters: [String : String] {
        get {
            let volume = Int (AVAudioSession.sharedInstance().outputVolume * 100)
            let info = [VTrackingKeyConnectivity : reachability.currentReachabilityStatus().trackingDescription, VTrackingKeyVolumeLevel : String(volume)]
            return info
        }
    }
    
    override init() { }
    
    init(trackingItem: VTracking) {
        self.trackingItem = trackingItem
    }
    
    private func formattedParameters(trackingURLObject: AnyObject?) -> [String : String]? {
        if let trackingURL = trackingURLObject as? String {
            var parameters = infoParameters
            parameters[VTrackingKeyUrls] = trackingURL
            return parameters
        } else {
            return nil
        }
    }
    
    func trackAutoplayStart() {
        if let trackingItem = trackingItem, parameters = formattedParameters(trackingItem.autoplayView) {
            trackingManager.trackEvent(VTrackingEventAutoplayDidStart, parameters: parameters)
        }
    }
    
    func trackAutoplayClick() {
        if let trackingItem = trackingItem, parameters = formattedParameters(trackingItem.autoplayClick) {
            trackingManager.trackEvent(VTrackingEventAutoplayClick, parameters: parameters)
        }
    }
    
    func trackAutoplayComplete25() {
        if let trackingItem = trackingItem, parameters = formattedParameters(trackingItem.autoplayComplete25) {
            trackingManager.trackEvent(VTrackingEventAutoplayDidComplete25, parameters: parameters)
        }
    }
    
    func trackAutoplayComplete50() {
        if let trackingItem = trackingItem, parameters = formattedParameters(trackingItem.autoplayComplete50) {
            trackingManager.trackEvent(VTrackingEventAutoplayDidComplete50, parameters: parameters)
        }
    }
    
    func trackAutoplayComplete75() {
        if let trackingItem = trackingItem, parameters = formattedParameters(trackingItem.autoplayComplete75) {
            trackingManager.trackEvent(VTrackingEventAutoplayDidComplete75, parameters: parameters)
        }
    }
    
    func trackAutoplayComplete100() {
        if let trackingItem = trackingItem, parameters = formattedParameters(trackingItem.autoplayComplete100) {
            trackingManager.trackEvent(VTrackingEventAutoplayDidComplete100, parameters: parameters)
        }
    }
    
    func trackAutoplayStall() {
        if let trackingItem = trackingItem, parameters = formattedParameters(trackingItem.autoplayViewStall) {
            trackingManager.trackEvent(VTrackingEventAutoplayDidStall, parameters: parameters)
        }
    }
}