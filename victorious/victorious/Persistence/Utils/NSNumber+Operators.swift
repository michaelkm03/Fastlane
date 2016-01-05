//
//  NSNumber+Operators.swift
//  victorious
//
//  Created by Patrick Lynch on 10/21/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation

/// These global operators clean up the syntax of code that has to mix values
/// of `NSNumber` and `Int` types.  This is most common with NSManagedObject subclasses
/// whose numeric and boolean attributes are always represented as `NSNumber`

public func +=( inout lhs: NSNumber?, rhs: Int ) -> NSNumber {
    let number = NSNumber(integer: (lhs?.integerValue ?? 0) + rhs )
    lhs = number
    return number
}

public func -=( inout lhs: NSNumber?, rhs: Int ) -> NSNumber {
    let number = NSNumber(integer: (lhs?.integerValue ?? 0) - rhs )
    lhs = number
    return number
}

public func +=( inout lhs: NSNumber, rhs: Int ) -> NSNumber {
    let number = NSNumber(integer: lhs.integerValue + rhs )
    lhs = number
    return number
}

public func -=( inout lhs: NSNumber, rhs: Int ) -> NSNumber {
    let number = NSNumber(integer: lhs.integerValue - rhs )
    lhs = number
    return number
}

public func +( lhs: NSNumber?, rhs: Int ) -> NSNumber {
    return NSNumber(integer: (lhs?.integerValue ?? 0) ) + 1
}

public func -( lhs: NSNumber?, rhs: Int ) -> NSNumber {
    return NSNumber(integer: (lhs?.integerValue ?? 0) ) - 1
}

public func +( lhs: NSNumber, rhs: Int ) -> NSNumber {
    return NSNumber(integer: lhs.integerValue + rhs )
}

public func -( lhs: NSNumber, rhs: Int ) -> NSNumber {
    return NSNumber(integer: lhs.integerValue - rhs )
}
