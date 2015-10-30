//
//  Dictionary+URLEncodedString.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/25/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation

private let keySeparator = "&"
private let valueSeparator = "="

private let queryPartAllowedCharacterSet: NSCharacterSet = {
    let mutableCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
    mutableCharacterSet.removeCharactersInString("?&=@")
    return mutableCharacterSet.copy() as! NSCharacterSet
}()

extension Dictionary {
    /// Returns the contents of this dictionary as a URL-encoded string
    /// (e.g. key=value&otherkey=othervalue&...
    public func vsdk_urlEncodedString() -> String {
        let encodedString = NSMutableString()
        for (key, value) in self {
            if let key = String(key).stringByAddingPercentEncodingWithAllowedCharacters(queryPartAllowedCharacterSet),
               let value = String(value).stringByAddingPercentEncodingWithAllowedCharacters(queryPartAllowedCharacterSet) {
                if encodedString.length != 0 {
                    encodedString.appendString(keySeparator)
                }
                encodedString.appendString(key)
                encodedString.appendString(valueSeparator)
                encodedString.appendString(value)
            }
        }
        return encodedString as String
    }
}

extension NSMutableURLRequest {
    /// Sets the HTTPMethod to "POST", the "Content-Type" to "application/x-www-form-urlencoded"
    /// and adds a URL-encoded HTTPBody.
    ///
    /// - warning: This function will overwrite any existing HTTPBody!
    ///
    /// - parameter postValues: The values to URL-encode and add to the HTTPBody
    public func vsdk_addURLEncodedFormPost<K, V>(postValues: [K : V]) {
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
