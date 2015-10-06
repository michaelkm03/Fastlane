//
//  FirstInstallDeviceIDManager.swift
//  victorious
//
//  Created by Tian Lan on 10/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import UIKit

class FirstInstallDeviceIDManager {
    
    // MARK: - Properties
    private let fileManager = NSFileManager()
    
    private var documentDirectory: NSURL? {
        return fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
    }
    
    // MARK: - Public API
    
    /// First try to read device id from a local file. If the file does not exists,
    /// acquire the current device ID and save it to the local file.
    /// - parameter forHeaderKey: the HTTP header key to extract info for
    /// - returns: the device ID read from local file or generated from current device ID
    func generateFirstInstallDeviceID(forHeaderKey key: String) -> String? {
        guard let deviceIDFileURL = documentDirectory?.URLByAppendingPathComponent(key),
            let path = deviceIDFileURL.path,
            let currentDeviceID = UIDevice.currentDevice().identifierForVendor?.UUIDString else {
                return nil
        }
        
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
    
    // MARK: - Private methods
    
    /// Retrive the device ID from provided path to file, if the file exists
    /// - parameter path: The string representation of path to target file
    /// - returns: The string representation of content of the file, or nil if reading failed
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
    
    /// Writes the device ID to provided file
    /// - parameter path: The string representation of path to the device ID file
    /// - parameter deviceID: the device ID to be written to file
    /// - returns: A Bool for whether the write was successful
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
    
    /// Exclude a directory from all backups of app data
    /// - parameter path: The string representation of path to target file
    /// - returns: A Bool for whether the exclusion was successful
    private func excludeBackupForFile(url: NSURL, shouldExcludeFromBack flag: Bool) -> Bool {
        do {
            try url.setResourceValue(flag, forKey: NSURLIsExcludedFromBackupKey)
            return true
        }
        catch {
            print ("Could not set resource value for key \(NSURLIsExcludedFromBackupKey)")
            return false
        }
    }
}