//
//  NSCharacterSet+VSDKURLParts.swift
//  victorious
//
//  Created by Josh Hinman on 2/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

private let queryPartAllowedCharacterSet: CharacterSet = {
    var queryCharacterSet = CharacterSet.urlPathAllowed
    queryCharacterSet.remove(charactersIn: ";/?:@&=+,$")
    return queryCharacterSet
}()

private let pathPartAllowedCharacterSet: CharacterSet = {
    var pathCharacterSet = CharacterSet.urlPathAllowed
    pathCharacterSet.remove(charactersIn: "/@:")
    return pathCharacterSet
}()

extension CharacterSet {
    /// Returns the character set for characters allowed in a query URL component.
    public static var vsdk_queryPartAllowedCharacterSet: CharacterSet {
        return queryPartAllowedCharacterSet
    }
    
    /// Returns the character set for characters allowed in a path URL component.
    public static var vsdk_pathPartAllowedCharacterSet: CharacterSet {
        return pathPartAllowedCharacterSet
    }
}

// MARK: - OBJC Compatibility!
extension NSCharacterSet {
    /// Returns the character set for characters allowed in a query URL component.
    public static var vsdk_queryPartAllowedCharacterSet: CharacterSet {
        return queryPartAllowedCharacterSet
    }
    
    /// Returns the character set for characters allowed in a path URL component.
    public static var vsdk_pathPartAllowedCharacterSet: CharacterSet {
        return pathPartAllowedCharacterSet
    }
}
