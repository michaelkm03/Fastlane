//
//  NSString+Emoji.swift
//  victorious
//
//  Created by Patrick Lynch on 12/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

import Foundation

public extension NSString {
    
    @objc public var lengthWithUnicode: Int {
        return countElements( (self as String) )
    }
    
}