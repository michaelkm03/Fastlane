//
//  FTUEVideoOperation.swift
//  victorious
//
//  Created by Michael Sena on 8/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class FTUEVideoOperation: Operation, VLightweightContentViewControllerDelegate {
    
    // Constant Keys
    let kFirstTimeContentKey = "firstTimeContent"
    private let kWelcomeStartKey = "welcome_start"
    private let kVideoStartedKey = "welcome_video_start"
    private let kVideoEndedKey = "welcome_video_end"
    private let kGetStartedTapKey = "get_started_tap"
    
    private let dependencyManager: VDependencyManager
    private let viewControllerToPresentOn: UIViewController
    private let firstTimeInstallHelper = VFirstTimeInstallHelper()
    private let sessionTimer: VSessionTimer
    
    init(dependencyManager: VDependencyManager, viewControllerToPresentOn: UIViewController, sessionTimer: VSessionTimer) {
        
        self.dependencyManager = dependencyManager
        self.sessionTimer = sessionTimer
        self.viewControllerToPresentOn = viewControllerToPresentOn

        super.init()
        
        qualityOfService = .UserInteractive
    }
    
    // MARK: - Override
    
    override func start() {
        super.start()
        
        dispatch_async( dispatch_get_main_queue() ) {
            
            self.beganExecuting()
            
            // Bail early if we have already seen the FTUE Video
            guard self.firstTimeInstallHelper.hasBeenShown() == false else {
                self.finishedExecuting()
                return
            }
            
            guard let config = self.dependencyManager.templateValueOfType(NSDictionary.self, forKey: self.kFirstTimeContentKey) as? [NSObject : AnyObject],
                let firstTimeContentDependencyManager = self.dependencyManager.childDependencyManagerWithAddedConfiguration(config),
                let lightWeightContentVC = firstTimeContentDependencyManager.templateValueOfType(VLightweightContentViewController.self,
                    forKey: self.kFirstTimeContentKey) as? VLightweightContentViewController else {
                        self.finishedExecuting()
                        return
            }
            
            lightWeightContentVC.delegate = self;
            self.viewControllerToPresentOn.presentViewController(lightWeightContentVC, animated: true) {
                self.firstTimeInstallHelper.savePlaybackDefaults()
            }
        }
    }
    
    // MARK: - VLightweightContentViewControllerDelegate
    
    func videoHasStartedInLightweightContentView(lightweightContentViewController: VLightweightContentViewController) {
        let sessionTime = NSNumber(unsignedLong: UInt(sessionTimer.sessionDuration))
        let params: [NSObject: AnyObject] = [
            VTrackingKeyUrls: self.dependencyManager.trackingURLsForKey(kVideoStartedKey),
            VTrackingKeySessionTime: sessionTime]
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectWelcomeGetStarted, parameters: params)
    }

    func videoHasCompletedInLightweightContentView(lightweightContentViewController: VLightweightContentViewController) {
        let sessionTime = NSNumber(unsignedLong: UInt(sessionTimer.sessionDuration))
        let params: [NSObject: AnyObject] = [
            VTrackingKeyUrls: self.dependencyManager.trackingURLsForKey(kVideoEndedKey),
            VTrackingKeySessionTime: sessionTime]
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectWelcomeGetStarted, parameters: params)
        onVideoFinished()
    }
    
    func failedToLoadSequenceInLightweightContentView(lightweightContentViewController: VLightweightContentViewController) {
        onVideoFinished()
    }
    
    func userWantsToDismissLightweightContentView(lightweightContentViewController: VLightweightContentViewController) {
        let sessionTime = NSNumber(unsignedLong: UInt(sessionTimer.sessionDuration))
        let params: [NSObject: AnyObject] = [
            VTrackingKeyUrls: self.dependencyManager.trackingURLsForKey(kGetStartedTapKey),
            VTrackingKeySessionTime: sessionTime]
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectWelcomeGetStarted, parameters: params)
        onVideoFinished()
    }
    
    // MARK: - Internal
    
    private func trackFirstTimeContentView() {
        let sessionTime = NSNumber(unsignedLong: UInt(sessionTimer.sessionDuration))
        let params: [NSObject: AnyObject] = [
            VTrackingKeySessionTime: sessionTime,
            VTrackingKeyUrls: self.dependencyManager.trackingURLsForKey(kWelcomeStartKey)]
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventWelcomeDidStart, parameters: params)
    }
    
    private func onVideoFinished() {
        viewControllerToPresentOn.dismissViewControllerAnimated(true) {
            self.finishedExecuting()
        }
    }
    
}
