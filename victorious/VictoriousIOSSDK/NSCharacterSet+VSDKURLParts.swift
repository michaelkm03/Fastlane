//
//  NSCharacterSet+VSDKURLParts.swift
//  victorious
//
//  Created by Josh Hinman on 2/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

private let queryPartAllowedCharacterSet: NSCharacterSet = {
    let mutableCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet.mutableCopy() as! NSMutableCharacterSet
    mutableCharacterSet.removeCharactersInString(";/?:@&=+,$")
    return mutableCharacterSet.copy() as! NSCharacterSet
}()

private let pathPartAllowedCharacterSet: NSCharacterSet = {
    let mutableCharacterSet = NSCharacterSet.URLPathAllowedCharacterSet.mutableCopy() as! NSMutableCharacterSet
    mutableCharacterSet.removeCharactersInString("/@:")
    return mutableCharacterSet.copy() as! NSCharacterSet
}()

extension NSCharacterSet {
    /// Returns the character set for characters allowed in a query URL component.
    public static var vsdk_queryPartAllowedCharacterSet: NSCharacterSet {
        return queryPartAllowedCharacterSet
    }
    
    /// Returns the character set for characters allowed in a path URL component.
    public static var vsdk_pathPartAllowedCharacterSet: NSCharacterSet {
        return pathPartAllowedCharacterSet
    }
}
