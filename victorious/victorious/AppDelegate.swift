//
//  AppDelegate.swift
//  victorious
//
//  Created by Sebastian Nystorm on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        guard !NSBundle.v_isTestBundle else {
            return true
        }

        #if V_ENABLE_TESTFAIRY
            let options = [TFSDKEnableCrashReporterKey: false]
            Testfairy.begin("c03fa570f9415585437cbfedb6d09ae87c7182c8", withOptions: options)
        #endif

        Crashlytics.startWithAPIKey("58f61748f3d33b03387e43014fdfff29c5a1da73")

        addLoginListener()

        VReachability.reachabilityForInternetConnection().startNotifier()

        configureAudioSessionCategory()

        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let mainStoryboard = UIStoryboard(name: kMainStoryboardName, bundle: nil)
        window?.rootViewController = mainStoryboard.instantiateInitialViewController()
        window?.makeKeyAndVisible()

        let timingTracker = DefaultTimingTracker.sharedInstance()
        timingTracker.startEvent(type: VAppTimingEventTypeAppStart)
        timingTracker.startEvent(type: VAppTimingEventTypeShowRegistration)

        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func applicationWillResignActive(application: UIApplication) { }

    func applicationDidEnterBackground(application: UIApplication) {
        savePersistentChanges()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        configureAudioSessionCategory()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // We don't need this yet, but it must be initialized now (see comments for sharedInstance method)
        VPurchaseManager.sharedInstance()
    }

    func applicationWillTerminate(application: UIApplication) {
        savePersistentChanges()
    }

    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        if FacebookHelper.canOpenURL(url) {
            let sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String
            let annotation = options[UIApplicationOpenURLOptionsAnnotationKey]
            return FBSDKApplicationDelegate.sharedInstance().application(app, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        }

        VRootViewController.sharedRootViewController()?.applicationOpenURL(url)

        return true
    }

    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        logger.verbose("handling events for background identifier -> \(identifier)")

        let uploadManager = VUploadManager.sharedManager()
        if uploadManager.isYourBackgroundURLSession(identifier) {
            uploadManager.backgroundSessionEventsCompleteHandler = completionHandler
            uploadManager.startURLSession()
        }
    }

    // MARK: - Notifications

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        VRootViewController.sharedRootViewController()?.applicationDidReceiveRemoteNotification(userInfo)
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        VPushNotificationManager.sharedPushNotificationManager().didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        VPushNotificationManager.sharedPushNotificationManager().didFailToRegisterForRemoteNotificationsWithError(error)
    }

    // MARK: - Orientation

    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        return .AllButUpsideDown
    }

    // MARK: - Private

    /// Listens to the login user notification in order to `register` the user with our services.
    private func addLoginListener() {
        NSNotificationCenter.defaultCenter().addObserverForName(kLoggedInChangedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notififcation) in
            if let currentUser = VCurrentUser.user() {
                #if V_ENABLE_TESTFAIRY
                    let userTraits = [TFSDKIdentityTraitNameKey: currentUser.displayName ?? "",
                                      TFSDKIdentityTraitEmailAddressKey: currentUser.username ?? ""]
                    TestFairy.identify(currentUser.remoteId.stringValue, traits:userTraits)
                #endif

                Crashlytics.setUserIdentifier(currentUser.remoteId.stringValue)
                Crashlytics.setUserEmail(currentUser.username ?? "")
                Crashlytics.setUserName(currentUser.displayName ?? "")

                logger.setUserIdentifier(currentUser.remoteId.stringValue)
            }
        }
    }

    private func configureAudioSessionCategory() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        } catch {
            logger.warning("Failed to set the AudioSession category with error ->\(error)")
        }
    }

    private func savePersistentChanges() {
        let persistentStore = PersistentStoreSelector.defaultPersistentStore
        do {
            try persistentStore.mainContext.save()
        } catch {
            logger.warning("Failed to save the persistent stores main context with error -> \(error)")
        }
    }
}
