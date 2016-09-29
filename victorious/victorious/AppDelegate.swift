//
//  AppDelegate.swift
//  victorious
//
//  Created by Sebastian Nystorm on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import Crashlytics
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        guard !Bundle.v_isTestBundle else {
            return true
        }

        #if V_ENABLE_TESTFAIRY
            let options = [TFSDKEnableCrashReporterKey: false]
            TestFairy.begin("c03fa570f9415585437cbfedb6d09ae87c7182c8", withOptions: options)
        #endif

        Crashlytics.start(withAPIKey: "58f61748f3d33b03387e43014fdfff29c5a1da73")

        addLoginListener()

        VReachability.forInternetConnection().startNotifier()

        configureAudioSessionCategory()

        window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard = UIStoryboard(name: kMainStoryboardName, bundle: nil)
        window?.rootViewController = mainStoryboard.instantiateInitialViewController()
        window?.makeKeyAndVisible()

        let timingTracker = DefaultTimingTracker.sharedInstance()
        timingTracker.startEvent(type: VAppTimingEventTypeAppStart)
        timingTracker.startEvent(type: VAppTimingEventTypeShowRegistration)

        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        configureAudioSessionCategory()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // We don't need this yet, but it must be initialized now (see comments for sharedInstance method)
        VPurchaseManager.sharedInstance()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if FacebookHelper.canOpenURL(url as NSURL) {
            let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String
            let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
            return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }

        VRootViewController.shared()?.applicationOpen(url)

        return true
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        Log.verbose("handling events for background identifier -> \(identifier)")

        // Future: Fix this ! imported from Objc
        let uploadManager = VUploadManager.shared()!
        if uploadManager.isYourBackgroundURLSession(identifier) {
            uploadManager.backgroundSessionEventsCompleteHandler = completionHandler
            uploadManager.startURLSession()
        }
    }

    // MARK: - Notifications

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        VRootViewController.shared()?.applicationDidReceiveRemoteNotification(userInfo)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        VPushNotificationManager.shared().didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        VPushNotificationManager.shared().didFailToRegisterForRemoteNotificationsWithError(error)
    }

    // MARK: - Orientation

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .allButUpsideDown
    }

    // MARK: - Private

    /// Listens to the login user notification in order to `register` the user with our services.
    fileprivate func addLoginListener() {
        NotificationCenter.default.addObserver(forName: .loggedInChanged, object: nil, queue: .main) { (notififcation) in
            if let currentUser = VCurrentUser.user {
                #if V_ENABLE_TESTFAIRY
                    let userTraits = [TFSDKIdentityTraitNameKey: currentUser.displayName ?? "",
                                      TFSDKIdentityTraitEmailAddressKey: currentUser.username ?? ""]
                    TestFairy.identify(String(currentUser.id), traits:userTraits)
                #endif

                Crashlytics.setUserIdentifier(String(currentUser.id))
                Crashlytics.setUserEmail(currentUser.username ?? "")
                Crashlytics.setUserName(currentUser.displayName ?? "")

                Log.setUserIdentifier(identifier: String(currentUser.id))
            }
        }
    }

    fileprivate func configureAudioSessionCategory() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        } catch {
            Log.warning("Failed to set the AudioSession category with error ->\(error)")
        }
    }
}
