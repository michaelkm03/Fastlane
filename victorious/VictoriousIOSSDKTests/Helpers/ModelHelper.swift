//
//  ModelHelper.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import VictoriousIOSSDK

/// Helps with creating test Sequence data
class ModelHelper {
    func createSequence(JSONFileName fileName: String) -> Sequence? {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource(fileName, withExtension: "json"),
            let mockData = NSData(contentsOfURL: url),
            let sequence = Sequence(json: JSON(data: mockData)) else {
                XCTFail("Failed to parse a sequence from \(fileName).json")
                return nil
        }

        return sequence
    }

    func createAdBreak(JSONFilename fileName: String) -> AdBreak? {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource(fileName, withExtension: "json"),
            let mockData = NSData(contentsOfURL: url),
            let adBreak = AdBreak(json: JSON(data: mockData)) else {
                XCTFail("Failed to parse a sequence from \(fileName).json")
                return nil
        }

        return adBreak
    }
}