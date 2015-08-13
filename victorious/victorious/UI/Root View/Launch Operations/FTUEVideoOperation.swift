//
//  FTUEVideoOperation.swift
//  victorious
//
//  Created by Michael Sena on 8/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class FTUEVideoOperation: NSOperation, VLightweightContentViewControllerDelegate {
    
    // Constant Keys
    private let firstTimeContentKey = "firstTimeContent"
    private let welcomeStartKey = "welcome_start"
    private let videoStartedKey = "welcome_video_start"
    private let videoEndedKey = "welcome_video_end"
    private let getStartedTapKey = "get_started_tap"
    
    private let dependencyManager: VDependencyManager
    private let firstTimeContentDependencyManager: VDependencyManager
    private let viewControllerToPresentOn: UIViewController
    private let firstTimeInstallHelper: VFirstTimeInstallHelper
    private let sessionTimer: VSessionTimer
    private var _executing : Bool
    private var _finished : Bool
    
    init(dependencyManager: VDependencyManager, viewControllerToPresentOn: UIViewController, sessionTimer: VSessionTimer) {
        _executing = false
        _finished = false
        self.dependencyManager = dependencyManager
        self.sessionTimer = sessionTimer
        var configuration = self.dependencyManager.templateValueOfType(NSDictionary.self, forKey: firstTimeContentKey) as! NSDictionary
        self.firstTimeContentDependencyManager = self.dependencyManager.childDependencyManagerWithAddedConfiguration(configuration as [NSObject : AnyObject])
        
        self.viewControllerToPresentOn = viewControllerToPresentOn
        firstTimeInstallHelper = VFirstTimeInstallHelper()
        
        super.init()
    }
    
    // MARK: - Override
    
    override func start() {
        super.start()

        // Bail early if we have already seen the FTUE Video
        if firstTimeInstallHelper.hasBeenShown() {
            executing = false
            finished = true
            return
        }
        
        executing = true
        finished = false

        let lightWeightContentVC = self.firstTimeContentDependencyManager.templateValueOfType(VLightweightContentViewController.self, forKey: firstTimeContentKey) as! VLightweightContentViewController

        lightWeightContentVC.delegate = self
        viewControllerToPresentOn.presentViewController(lightWeightContentVC, animated: true) { () -> Void in
            self.firstTimeInstallHelper.savePlaybackDefaults()
        }
        
    }
    
    // MARK: - VLightweightContentViewControllerDelegate
    
    func videoHasStartedInLightweightContentView(lightweightContentViewController: VLightweightContentViewController!) {
        let sessionTime = NSNumber(unsignedLong: UInt(sessionTimer.sessionDuration))
        let params: [NSObject: AnyObject] = [
            VTrackingKeyUrls: self.firstTimeContentDependencyManager.trackingURLsForKey(videoStartedKey),
            VTrackingKeySessionTime: sessionTime]
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectWelcomeGetStarted, parameters: params)
    }

    func videoHasCompletedInLightweightContentView(lightweightContentViewController: VLightweightContentViewController!) {
        let sessionTime = NSNumber(unsignedLong: UInt(sessionTimer.sessionDuration))
        let params: [NSObject: AnyObject] = [
            VTrackingKeyUrls: self.firstTimeContentDependencyManager.trackingURLsForKey(videoEndedKey),
            VTrackingKeySessionTime: sessionTime]
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectWelcomeGetStarted, parameters: params)
        onVideoFinished()
    }
    
    func failedToLoadSequenceInLightweightContentView(lightweightContentViewController: VLightweightContentViewController!) {
        onVideoFinished()
    }
    
    func userWantsToDismissLightweightContentView(lightweightContentViewController: VLightweightContentViewController!) {
        let sessionTime = NSNumber(unsignedLong: UInt(sessionTimer.sessionDuration))
        let params: [NSObject: AnyObject] = [
            VTrackingKeyUrls: self.firstTimeContentDependencyManager.trackingURLsForKey(getStartedTapKey),
            VTrackingKeySessionTime: sessionTime]
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectWelcomeGetStarted, parameters: params)
        onVideoFinished()
    }
    
    // MARK: - Internal
    
    private func trackFirstTimeContentView() {
        let sessionTime = NSNumber(unsignedLong: UInt(sessionTimer.sessionDuration))
        let params: [NSObject: AnyObject] = [
            VTrackingKeySessionTime: sessionTime,
            VTrackingKeyUrls: self.firstTimeContentDependencyManager.trackingURLsForKey(welcomeStartKey)]
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventWelcomeDidStart, parameters: params)
    }
    
    private func onVideoFinished() {
        viewControllerToPresentOn.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.executing = false
            self.finished = true
        })
    }
    
    // MARK: - KVO-able NSNotification State
    
    override var executing : Bool {
        get {return _executing }
        set {
            willChangeValueForKey("isExecuting")
            _executing = newValue
            didChangeValueForKey("isExecuting")
        }
    }
    
    override var finished : Bool {
        get {return _finished }
        set {
            willChangeValueForKey("isFinished")
            _finished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    
}
