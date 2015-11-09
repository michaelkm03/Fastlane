//
//  NSSet+Extensions.swift
//  VictoriousIOSSDK
//
//  Created by Patrick Lynch on 10/21/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation
import CoreData

/// ManagedSet is an of NSSet and NSOrderedSet that allows the overloaded operators defined
/// in this file to apply to both types of collections.
public protocol ManagedSet {
    var allObjects: [AnyObject] { get }
    init( array: [AnyObject] )
    init()
    func objects<T>() -> [T]
}

public extension ManagedSet {
    public func objects<T>() -> [T] {
        return self.allObjects.filter({ $0 is T }).map({ $0 as! T })
    }
}

extension NSOrderedSet : ManagedSet {
    public var allObjects: [AnyObject] { return self.array }
}

extension NSSet : ManagedSet {}

public func +=( inout lhs: NSNumber, rhs: Int ) -> NSNumber {
    lhs = NSNumber(integer: lhs.integerValue + rhs )
    return lhs
}

public func -=( inout lhs: NSNumber, rhs: Int ) -> NSNumber {
    lhs = NSNumber(integer: lhs.integerValue - rhs )
    return lhs
}

public func += <T: ManagedSet>(inout lhs: T, rhs: NSManagedObject) -> T {
    var array = lhs.allObjects as? [NSManagedObject] ?? [NSManagedObject]()
    array.append( rhs )
    let newValue = T(array: array)
    lhs = newValue
    return T(array: array)
}

public func -= <T: ManagedSet>(inout lhs: T, rhs: NSManagedObject) -> T {
    var array = lhs.allObjects as? [NSManagedObject] ?? [NSManagedObject]()
    array = array.filter { $0 != rhs }
    let newValue = T(array: array)
    lhs = newValue
    return T(array: array)
}

public func += <T: ManagedSet>(inout lhs: T?, rhs: NSManagedObject) -> T {
    var array = lhs?.allObjects as? [NSManagedObject] ?? [NSManagedObject]()
    array.append( rhs )
    let newValue = T(array: array)
    lhs = newValue
    return T(array: array)
}

public func -= <T: ManagedSet>(inout lhs: T?, rhs: NSManagedObject) -> T {
    var array = lhs?.allObjects as? [NSManagedObject] ?? [NSManagedObject]()
    array = array.filter { $0 != rhs }
    let newValue = T(array: array)
    lhs = newValue
    return T(array: array)
}

public func += <T: ManagedSet>(inout lhs: T?, rhs: [NSManagedObject]) -> T {
    var array = lhs?.allObjects as? [NSManagedObject] ?? [NSManagedObject]()
    array = array + rhs
    let newValue = T(array: array)
    lhs = newValue
    return T(array: array)
}

public func += <T: ManagedSet>(inout lhs: T, rhs: [NSManagedObject]) -> T {
    var array = lhs.allObjects
    array = array + rhs
    let newValue = T(array: array)
    lhs = newValue
    return T(array: array)
}

public func +<T: ManagedSet>( lhs: T?, rhs: NSManagedObject ) -> T {
    var array = lhs?.allObjects as? [NSManagedObject] ?? [NSManagedObject]()
    array.append( rhs )
    return T(array: array)
}

public func +<T: ManagedSet>( lhs: T?, rhs: [NSManagedObject] ) -> T {
    var array = lhs?.allObjects as? [NSManagedObject] ?? [NSManagedObject]()
    array = array + rhs
    return T(array: array)
}

public func -<T: ManagedSet>( lhs: T?, rhs: NSManagedObject ) -> T {
    var array = lhs?.allObjects as? [NSManagedObject] ?? [NSManagedObject]()
    array = array.filter { $0 != rhs }
    return T(array: array)
}

public func -<T: ManagedSet>( lhs: T?, rhs: [NSManagedObject] ) -> T {
    var array = lhs?.allObjects as? [NSManagedObject] ?? [NSManagedObject]()
    array = array.filter { !rhs.contains($0) }
    return T(array: array)
}
