//
//  NSDictionary+URLEncodedString.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/25/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation

private let keySeparator = "&"
private let valueSeparator = "="
private let arrayValueSeperator = "[]"

extension Dictionary {
    public func vsdk_urlEncodedString() -> String {
        var encodedString = String()
        for (key, value) in self {
            if let key = String(describing: key).addingPercentEncoding(withAllowedCharacters: .vsdk_queryPartAllowedCharacterSet) {
                
                // Checks for an array value and encodes it appropriately
                if let valueArray = value as? NSArray {
                    for value in valueArray {
                        if let value = String(describing: value).addingPercentEncoding(withAllowedCharacters: .vsdk_queryPartAllowedCharacterSet) {
                            encodedString.appendURLParameter(key: key, value: value, useArraySeperator: true)
                        }
                    }
                }
                else if let value = String(describing: value).addingPercentEncoding(withAllowedCharacters: .vsdk_queryPartAllowedCharacterSet) {
                    encodedString.appendURLParameter(key: key, value: value)
                }
            }
        }
        return encodedString
    }
}

fileprivate extension String {
    mutating func appendURLParameter(key: String, value: String, useArraySeperator: Bool = false) {
        if self.characters.count != 0 {
            self.append(keySeparator)
        }
        self.append(key)
        if useArraySeperator {
            self.append(arrayValueSeperator)
        }
        self.append(valueSeparator)
        self.append(value)
    }
}

extension URLRequest {
    /// Sets the HTTPMethod to "POST", the "Content-Type" to "application/x-www-form-urlencoded"
    /// and adds a URL-encoded HTTPBody.
    ///
    /// - warning: This function will overwrite any existing HTTPBody!
    ///
    /// - parameter postValues: The values to URL-encode and add to the HTTPBody
    public mutating func vsdk_addURLEncodedFormPost(_ postValues: [String: Any]) {
        httpMethod = "POST"
        addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        httpBody = postValues.vsdk_urlEncodedString().data(using: String.Encoding.utf8)
    }
}
