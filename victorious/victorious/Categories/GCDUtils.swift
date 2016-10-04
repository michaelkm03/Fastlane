//
//  GCDUtils.swift
//  victorious
//
//  Created by Patrick Lynch on 8/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// Executes a closure using `dispatch_after`, saving the need for the cumbersome overhead
/// of getting the correct `disaptch_time_t` value.
///
/// - parameter delay: The delay in seconds
/// - parameter closure: The closure to execute after the delay
func dispatch_after( _ delay: TimeInterval, _ closure: @escaping () -> () ) {
    
    let time = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter( deadline: time, execute: closure)
}


/// Executes a closure using `dispatch_after`, saving the need for the cumbersome overhead
/// of getting the correct `disaptch_time_t` value.
func dispatch_sync<T>( _ queue: DispatchQueue, closure: () -> T ) -> T {
    var output: T?
    queue.sync {
        output = closure()
    }
    return output!
}
