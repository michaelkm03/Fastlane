//
//  FirstInstallManager.swift
//  victorious
//
//  Created by Tian Lan on 10/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import UIKit

@objc class FirstInstallManager: NSObject {
    
    // MARK: - First Install Reporting
    
    let appFirstInstallDefaultsKey = "com.victorious.VAppDelegate.AppInstallEventTracked"
    
    let appFirstLaunchDefaultsKey = "com.victorious.FirstInstallManager.AppLaunchingForTheFirstTime"
    
    var trackingManager: VEventTracker = VTrackingManager.sharedInstance()

    func reportFirstInstallIfNeeded(withTrackingURLs urls: [String]) {
        // If first install tracking already fired, we should return early
        guard isFirstInstall else {
            // We record `App has launched for the first time` after the second time launch
            if isFirstLaunch {
                NSUserDefaults.standardUserDefaults().setValue(true, forKey: appFirstLaunchDefaultsKey)
            }
            
            return
        }
        
        let installDate = NSDate()
        let trackingParameters = [VTrackingKeyTimeStamp: installDate, VTrackingKeyUrls: urls]
        trackingManager.trackEvent(VTrackingEventApplicationFirstInstall, parameters: trackingParameters)
        NSUserDefaults.standardUserDefaults().setValue(true, forKey: appFirstInstallDefaultsKey)
    }
    
    // Tracks whether the `app_install` tracking call is already fired
    var isFirstInstall: Bool {
        return NSUserDefaults.standardUserDefaults().valueForKey(appFirstInstallDefaultsKey) == nil
    }
    
    // Tracks whether the app is running for the first time
    var isFirstLaunch: Bool {
        return NSUserDefaults.standardUserDefaults().valueForKey(appFirstLaunchDefaultsKey) == nil
    }
    
    // MARK: - Device ID
    
    static let defaultDeviceIDFileName = "FirstInstallDeviceID.txt"
    private let fileManager = NSFileManager()
    private var documentDirectory: NSURL? {
        return fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
    }
    
    /// First try to read device id from a local file. If the file does not exists,
    /// acquire the current device ID and save it to the local file.
    /// - parameter withFileName: the name of the file to store device ID
    /// - returns: the device ID read from local file or generated from current device ID
    func generateFirstInstallDeviceID(withFileName filename: String = defaultDeviceIDFileName) -> String? {
        guard let deviceIDFileURL = documentDirectory?.URLByAppendingPathComponent(filename),
            let path = deviceIDFileURL.path else {
                return nil
        }
        
        let currentDeviceID = UIDevice.currentDevice().v_authorizationDeviceID
        
        // Tries to read from local file first
        if let retrievedDeviceID = readDeviceIDFromFile(path) {
            return retrievedDeviceID
        }
        // If the local file does not exist, create a new one with the current Device ID
        else {
            writeDeviceIDToFile(path, deviceID: currentDeviceID)
            excludeBackupForFile(deviceIDFileURL, shouldExcludeFromBack: true)
            return currentDeviceID
        }
    }
    
    private func readDeviceIDFromFile(path: String) -> String? {
        if !fileManager.fileExistsAtPath(path) {
            return nil
        }
        
        do {
            let retrivedDeviceID = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
            return retrivedDeviceID
        }
        catch {
            print("Could not read device ID from file: \(path)")
            return nil
        }
    }
    
    private func writeDeviceIDToFile(path: String, deviceID id: String) -> Bool {
        do {
            try id.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
            return true
        }
        catch {
            print("Could not write device ID to file: \(path)")
            return false
        }
    }

    private func excludeBackupForFile(url: NSURL, shouldExcludeFromBack flag: Bool) -> Bool {
        do {
            try url.setResourceValue(flag, forKey: NSURLIsExcludedFromBackupKey)
            return true
        }
        catch {
            print("Could not set resource value for key \(NSURLIsExcludedFromBackupKey)")
            return false
        }
    }
}
