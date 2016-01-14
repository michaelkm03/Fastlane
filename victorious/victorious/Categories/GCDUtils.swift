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
func dispatch_after( delay:NSTimeInterval, _ closure:()->() ) {
    
    let time = dispatch_time( DISPATCH_TIME_NOW,  Int64(delay * Double(NSEC_PER_SEC)) )
    dispatch_after( time, dispatch_get_main_queue(), closure)
}


/// Executes a closure using `dispatch_after`, saving the need for the cumbersome overhead
/// of getting the correct `disaptch_time_t` value.
func dispatch_sync<T>( queue: dispatch_queue_t, closure: ()->T ) -> T {
    var output: T?
    dispatch_sync( queue ) {
        output = closure()
    }
    return output!
}
