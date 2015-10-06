//
//  FirstInstallDeviceIDManagerTests.swift
//  victorious
//
//  Created by Tian Lan on 10/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit
import XCTest

class FirstInstallDeviceIDManagerTests: XCTestCase {
    let deviceIDManager = FirstInstallDeviceIDManager()
    let deviceIDHeaderKey = "X-Client-Install-Device-ID"
    let tempKey = "TemporaryKey"
    let fileManager = NSFileManager()
    var docDir: NSURL? {
        return fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
    }
    
    func testGenerationFromExistingFile() {
        let deviceIDURL = docDir?.URLByAppendingPathComponent(deviceIDHeaderKey)
        let deviceIDPath = deviceIDURL?.path
        
        do {
            let retrievedDeviceID = try NSString(contentsOfFile: deviceIDPath!, encoding: NSUTF8StringEncoding) as String
            let generatedDeviceID = deviceIDManager.generateFirstInstallDeviceID(forHeaderKey: deviceIDHeaderKey)
            XCTAssertEqual(retrievedDeviceID, generatedDeviceID)
        }
        catch {
            XCTAssert(false, "failed to read from file \(deviceIDPath)")
        }
    }
    
    func testGenerationWithoutFile() {
        let tempURL = docDir?.URLByAppendingPathComponent(tempKey)
        let tempPath = tempURL?.path
        
        // Create a temp file with current device ID in it
        deviceIDManager.generateFirstInstallDeviceID(forHeaderKey: tempKey)
        
        do {
            let retrivedDeviceID = try NSString(contentsOfFile:tempPath!, encoding: NSUTF8StringEncoding) as String
            let currentDeviceID = UIDevice.currentDevice().identifierForVendor?.UUIDString
            XCTAssertEqual(retrivedDeviceID, currentDeviceID)
        }
        catch {
            XCTAssert(false, "failed to read from file \(tempPath)")
        }
        
        do {
            try fileManager.removeItemAtURL(tempURL!)
        }
        catch {
            XCTAssert(false, "failed to delete the temporary directory created")
        }
    }
}
