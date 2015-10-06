//
//  NSFileManager+VIctoriousAdditions.swift
//  victorious
//
//  Created by Tian Lan on 10/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// An extension to NSFileManager for Victorious Apps' additional functionalities
extension NSFileManager {
    
    // MARK: - Properties
    
    /// returns the Document directory of in user domain
    var documentDirectory: NSURL? {
        return URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
    }
    
    // MARK: - General Utilities
    
    /// Retrive a string from provided path to file
    /// - parameter path: The string representation of path to target file
    /// - returns: The string representation of content of the file
    func readStringFromFile(path: String) -> String? {
        if !fileExistsAtPath(path) {
            return nil
        }
        do {
            let retrivedDeviceID = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
            return retrivedDeviceID
        }
        catch {
            print("Could not read the existing file: \(path)")
            return nil
        }
    }
    
    /// Writes a string to provided path to file
    /// - parameter path: The string representation of path to target file
    /// - returns: A Bool for whether the write was successful
    func writeStringToFile(path: String, valueToWrite value: String) -> Bool {
        do {
            try value.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
            return true
        }
        catch {
            print("Could not write to file: \(path)")
            return false
        }
    }
    
    /// Exclude a directory from all backups of app data
    /// - parameter path: The string representation of path to target file
    /// - returns: A Bool for whether the exclusion was successful
    func excludeBackupForFile(url: NSURL, shouldExcludeFromBack flag: Bool) -> Bool {
        do {
            try url.setResourceValue(flag, forKey: NSURLIsExcludedFromBackupKey)
            return true
        }
        catch {
            print ("Could not set resource value for key \(NSURLIsExcludedFromBackupKey)")
            return false
        }
    }
    
    // MARK: - URL request helpers
    
    /// Try to read device id from local file. If the file does not exists,
    /// acquire the current device ID and save it to a local file.
    /// - parameter forHeaderKey: the HTTP header key to extract info for
    /// - returns: the device ID read from local file
    func readDeviceIDFromLocalFile(forHeaderKey key: String) -> String? {
        guard let deviceIDFileURL = documentDirectory?.URLByAppendingPathComponent(key),
            let path = deviceIDFileURL.path,
            let currentDeviceID = UIDevice.currentDevice().identifierForVendor?.UUIDString else {
                return nil
        }
        
        if let retrivedDeviceID = readStringFromFile(path) {
            return retrivedDeviceID
        }
        else {
            writeStringToFile(path, valueToWrite: currentDeviceID)
            excludeBackupForFile(deviceIDFileURL, shouldExcludeFromBack: true)
            return currentDeviceID
        }
    }
}