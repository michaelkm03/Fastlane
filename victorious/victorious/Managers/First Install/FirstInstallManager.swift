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
                UserDefaults.standard.setValue(true, forKey: appFirstLaunchDefaultsKey)
            }
            
            return
        }
        
        trackingManager.trackEvent(VTrackingEventApplicationFirstInstall, parameters: [
            VTrackingKeyTimeStamp: Date(),
            VTrackingKeyUrls: urls
        ])
        
        UserDefaults.standard.setValue(true, forKey: appFirstInstallDefaultsKey)
    }
    
    // Tracks whether the `app_install` tracking call is already fired
    var isFirstInstall: Bool {
        return UserDefaults.standard.value(forKey: appFirstInstallDefaultsKey) == nil
    }
    
    // Tracks whether the app is running for the first time
    var isFirstLaunch: Bool {
        return UserDefaults.standard.value(forKey: appFirstLaunchDefaultsKey) == nil
    }
    
    // MARK: - Device ID
    
    static let defaultDeviceIDFileName = "FirstInstallDeviceID.txt"
    fileprivate let fileManager = FileManager()
    fileprivate var documentDirectory: URL? {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    /// First try to read device id from a local file. If the file does not exists,
    /// acquire the current device ID and save it to the local file.
    /// - parameter withFileName: the name of the file to store device ID
    /// - returns: the device ID read from local file or generated from current device ID
    func generateFirstInstallDeviceID(withFileName filename: String = defaultDeviceIDFileName) -> String? {
        guard let deviceIDFileURL = documentDirectory?.appendingPathComponent(filename) else {
            return nil
        }
        
        let path = deviceIDFileURL.path
        let currentDeviceID = UIDevice.current.v_authorizationDeviceID
        
        // Tries to read from local file first
        if let retrievedDeviceID = readDeviceIDFromFile(path) {
            return retrievedDeviceID
        }
        // If the local file does not exist, create a new one with the current Device ID
        else {
            _ = writeDeviceIDToFile(path, deviceID: currentDeviceID)
            _ = excludeBackupForFile(deviceIDFileURL, shouldExcludeFromBack: true)
            return currentDeviceID
        }
    }
    
    fileprivate func readDeviceIDFromFile(_ path: String) -> String? {
        if !fileManager.fileExists(atPath: path) {
            return nil
        }
        
        do {
            let retrivedDeviceID = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue) as String
            return retrivedDeviceID
        }
        catch {
            print("Could not read device ID from file: \(path)")
            return nil
        }
    }
    
    fileprivate func writeDeviceIDToFile(_ path: String, deviceID id: String) -> Bool {
        do {
            try id.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
            return true
        }
        catch {
            print("Could not write device ID to file: \(path)")
            return false
        }
    }

    fileprivate func excludeBackupForFile(_ url: URL, shouldExcludeFromBack flag: Bool) -> Bool {
        do {
            try (url as NSURL).setResourceValue(flag, forKey: URLResourceKey.isExcludedFromBackupKey)
            return true
        }
        catch {
            print("Could not set resource value for key \(URLResourceKey.isExcludedFromBackupKey)")
            return false
        }
    }
}
