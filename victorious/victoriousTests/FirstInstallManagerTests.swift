//
//  FirstInstallManagerTests.swift
//  victorious
//
//  Created by Tian Lan on 10/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit
import XCTest
@testable import victorious
@testable import VictoriousIOSSDK

class FirstInstallManagerTests: XCTestCase {
    
    let firstInstallManager = FirstInstallManager()
    let testTrackingManager = TestTrackingManager()
    
    override func setUp() {
        firstInstallManager.trackingManager = testTrackingManager
        NSUserDefaults.standardUserDefaults().removeObject(forKey: firstInstallManager.appFirstInstallDefaultsKey)
    }
    
    // MARK: - First Install Reporting
    
    let trackingURLs = ["url1", "url2"]
    
    func testFirstInstallReporting() {
        XCTAssertTrue(firstInstallManager.isFirstInstall)
        firstInstallManager.reportFirstInstallIfNeeded(withTrackingURLs: trackingURLs)
        XCTAssertFalse(firstInstallManager.isFirstInstall)
        XCTAssertEqual(testTrackingManager.trackEventCalls.count, 1)
        
        let event = testTrackingManager.trackEventCalls.first!
        XCTAssertEqual(event.eventName, VTrackingEventApplicationFirstInstall)
        
        let parameters = event.parameters!
        XCTAssertEqual(parameters[VTrackingKeyUrls] as! [String], trackingURLs)
    }
    
    
    // MARK: - First Install Device ID
    
    let testingDeviceID = "testingDeviceID"
    let testingFileName = "testingFile.txt"
    let fileManager = NSFileManager()
    
    var testingFileURL: NSURL? {
        let docDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
        return docDir?.URLByAppendingPathComponent(testingFileName)
    }
    
    var testingFilePath: String? {
        return testingFileURL?.path
    }
    
    func testGenerationFromExistingFile() {
        do {
            try testingFileName.writeToFile(testingFilePath!, atomically: true, encoding: NSUTF8StringEncoding)
        }
        catch {
            XCTAssert(false, "failed to write to file \(testingFilePath)")
        }
        
        do {
            let retrievedDeviceID = try NSString(contentsOfFile: testingFilePath!, encoding: NSUTF8StringEncoding) as String
            let generatedDeviceID = firstInstallManager.generateFirstInstallDeviceID(withFileName: testingFileName)
            XCTAssertEqual(retrievedDeviceID, generatedDeviceID)
        }
        catch {
            XCTAssert(false, "failed to read from file \(testingFilePath)")
        }
        
        do {
            try fileManager.removeItemAtURL(testingFileURL!)
        }
        catch {
            XCTAssert(false, "failed to delete the temporary directory created")
        }
    }
    
    func testGenerationWithoutFile() {
        // Create a testing file with testing device ID in it
        firstInstallManager.generateFirstInstallDeviceID(withFileName: testingFileName)
        
        do {
            let retrivedDeviceID = try NSString(contentsOfFile: testingFilePath!, encoding: NSUTF8StringEncoding) as String
            let currentDeviceID = UIDevice.currentDevice().v_authorizationDeviceID
            XCTAssertEqual(retrivedDeviceID, currentDeviceID)
        }
        catch {
            XCTAssert(false, "failed to read from file \(testingFilePath)")
        }
        
        do {
            try fileManager.removeItemAtURL(testingFileURL!)
        }
        catch {
            XCTAssert(false, "failed to delete the temporary directory created")
        }
    }
}
