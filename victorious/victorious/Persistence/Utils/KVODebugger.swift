//
//  KVODebugger.swift
//  victorious
//
//  Created by Patrick Lynch on 12/2/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Provides some useful debugging utilities when using Key-Value Observing
@objc class KVODebugger: NSObject {
    
    /// Parses the `change` dictionary and prints out the change that has been observed
    class func printObservation( keyPath keyPath: String, object: NSObject, change: NSDictionary?) {
        let objectType = NSStringFromClass(object.classForCoder)
        if let value = change?[ NSKeyValueChangeKindKey ] as? UInt,
            let kind = NSKeyValueChange(rawValue:value) {
                switch kind {
                case .Setting:
                    print( "KVO :: \(objectType) :: Setting \(keyPath)" )
                case .Insertion:
                    print( "KVO :: \(objectType) :: Inserting \(keyPath)" )
                case .Removal:
                    print( "KVO :: \(objectType) :: Removing \(keyPath)" )
                case .Replacement:
                    print( "KVO :: \(objectType) :: Replacing \(keyPath)" )
                }
        }
    }
}
