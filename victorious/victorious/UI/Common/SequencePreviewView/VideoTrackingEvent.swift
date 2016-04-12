//
//  VideoTrackingEvent.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class VideoTrackingEvent: NSObject {
    
    var name: String
    var urls: AnyObject
    var loadTime: NSNumber?
    var context: StreamCellContext?
    var currentTime: NSNumber?
    var autoPlay: Bool = false
    
    init(name: String, urls: AnyObject) {
        self.name = name
        self.urls = urls
    }
    
    func track() {
        let reachability = VReachability.reachabilityForInternetConnection()
        let connectivityString = reachability.reachabilityStatusDescription(reachability.currentReachabilityStatus())
        let outputVolume = Int(AVAudioSession.sharedInstance().outputVolume * 100.0)
        let volumeString = String(outputVolume) ?? ""
        let trackingId: String = {
            if let context = context {
                let identifier = context.fromShelf ? context.stream.shelfId : context.stream.trackingIdentifier
                return identifier ?? ""
            }
            return ""
        }()
        
        let params = [
            VTrackingKeyAutoplay: autoPlay ? "true" : "false",
            VTrackingKeyConnectivity: connectivityString,
            VTrackingKeyVolumeLevel: volumeString,
            VTrackingKeyUrls: self.urls,
            VTrackingKeyStreamId: trackingId,
            VTrackingKeyTimeCurrent: String(currentTime?.floatValue ?? 0) ?? ""
        ]
        VTrackingManager.sharedInstance().trackEvent( name, parameters: params )
    }
}

@objc protocol VideoTracking {
    func trackAutoplayEvent(event: VideoTrackingEvent)
    func additionalInfo() -> [String: AnyObject]
}
