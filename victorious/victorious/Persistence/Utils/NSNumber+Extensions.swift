//
//  NSSet+Extensions.swift
//  VictoriousIOSSDK
//
//  Created by Patrick Lynch on 10/21/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation

public func +=( inout lhs: NSNumber, rhs: Int ) -> NSNumber {
    lhs = NSNumber(integer: lhs.integerValue + rhs )
    return lhs
}

public func -=( inout lhs: NSNumber, rhs: Int ) -> NSNumber {
    lhs = NSNumber(integer: lhs.integerValue - rhs )
    return lhs
}

public func +=( inout lhs: NSNumber, rhs: Int64 ) -> NSNumber {
    lhs = NSNumber(longLong: lhs.longLongValue + rhs )
    return lhs
}

public func -=( inout lhs: NSNumber, rhs: Int64 ) -> NSNumber {
    lhs = NSNumber(longLong: lhs.longLongValue - rhs )
    return lhs
}

extension NSNumber {
    
    convenience init?( v_longLong longLong: Int64? ) {
        if let longLong = longLong {
            self.init( longLong: longLong )
        } else {
            return nil
        }
    }
}