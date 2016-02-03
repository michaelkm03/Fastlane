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

private let queryPartAllowedCharacterSet: NSCharacterSet = {
    let mutableCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
    mutableCharacterSet.removeCharactersInString(";/?:@&=+,$")
    return mutableCharacterSet.copy() as! NSCharacterSet
}()

extension NSDictionary {
    public func vsdk_urlEncodedString() -> String {
        let encodedString = NSMutableString()
        for (key, value) in self {
            if let key = String(key).stringByAddingPercentEncodingWithAllowedCharacters(queryPartAllowedCharacterSet) {
                
                // Checks for an array value and encodes it appropriately
                if let valueArray = value as? NSArray {
                    for value in valueArray {
                        if let value = String(value).stringByAddingPercentEncodingWithAllowedCharacters(queryPartAllowedCharacterSet) {
                            encodedString.appendURLParameter(key, value: value, useArraySeperator: true)
                        }
                    }
                }
                else if let value = String(value).stringByAddingPercentEncodingWithAllowedCharacters(queryPartAllowedCharacterSet) {
                    encodedString.appendURLParameter(key, value: value)
                }
            }
            
        }
        return encodedString as String
    }
}

private extension NSMutableString {
    func appendURLParameter(key: String, value: String, useArraySeperator: Bool = false) {
        if self.length != 0 {
            self.appendString(keySeparator)
        }
        self.appendString(key)
        if useArraySeperator {
            self.appendString(arrayValueSeperator)
        }
        self.appendString(valueSeparator)
        self.appendString(value)
    }
}

extension NSMutableURLRequest {
    /// Sets the HTTPMethod to "POST", the "Content-Type" to "application/x-www-form-urlencoded"
    /// and adds a URL-encoded HTTPBody.
    ///
    /// - warning: This function will overwrite any existing HTTPBody!
    ///
    /// - parameter postValues: The values to URL-encode and add to the HTTPBody
    public func vsdk_addURLEncodedFormPost(postValues: NSDictionary) {
        HTTPMethod = "POST"
        addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        HTTPBody = postValues.vsdk_urlEncodedString().dataUsingEncoding(NSUTF8StringEncoding)
    }
}

extension NSCharacterSet {
    /// Returns the character set for characters allowed in a query URL component.
    public static var vsdk_queryPartAllowedCharacterSet: NSCharacterSet {
        return queryPartAllowedCharacterSet
    }
}
