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
    
    /// returns the Document directory of in user domain
    var documentDirectory: NSURL? {
        return URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
    }
    
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
}