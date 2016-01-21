//
//  NSDate+ComparableEquatable.swift
//  victorious
//
//  Created by Michael Sena on 8/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension NSDate: Comparable {}

func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.isEqualToDate(rhs)
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedAscending
}

public func >(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedDescending
}
