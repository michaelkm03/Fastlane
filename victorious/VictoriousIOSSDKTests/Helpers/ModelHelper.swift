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

/// Helps with creating test models
class ModelHelper {
    func createModel<T: ModelType>(JSONFileName fileName: String) -> T? {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource(fileName, withExtension: "json"),
            let mockData = NSData(contentsOfURL: url),
            let modelInstance = T(json: JSON(data: mockData)) else {
                XCTFail("Failed to parse a sequence from \(fileName).json")
                return nil
        }

        return modelInstance
    }
}
