//
//  ModelHelper.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import SwiftyJSON

/// Helps with creating test models
class ModelHelper {
    func createModel<T: JSONDeseriealizable>(JSONFileName fileName: String) -> T? {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource(fileName, withExtension: "json"),
            let mockData = NSData(contentsOfURL: url) else {
                print("Failed to read data from \(fileName).json")
                return nil
        }

        return T(json: JSON(data: mockData))
    }
}
