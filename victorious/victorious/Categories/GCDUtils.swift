//
//  GCDUtils.swift
//  victorious
//
//  Created by Patrick Lynch on 8/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// Dispatchs provided closure after delay, saving the need for the cumbersome overhead
/// of getting the correct `disaptch_time_t` value
///
/// :param: The delay in seconds
func dispatch_after( delay:NSTimeInterval, closure:()->() ) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}
