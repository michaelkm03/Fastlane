//
//  NSString+Unicode.swift
//  victorious
//
//  Created by Patrick Lynch on 12/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

import Foundation

public extension NSString
{
    /**
     * Returns the actual number of unicode characters present in the string.
     * Intended for getting accurate character count that accounts for emojis, which
     * can be counted as 2 or more characters using NSString's `length` property.
     */
    @objc public var lengthWithUnicode: Int
    {
        return countElements( self as String )
    }
    
}