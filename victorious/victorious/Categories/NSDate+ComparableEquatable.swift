//
//  NSDate+ComparableEquatable.swift
//  victorious
//
//  Created by Michael Sena on 8/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension Date: Comparable {}

func ==(lhs: Date, rhs: Date) -> Bool {
    return (lhs == rhs)
}

public func <(lhs: Date, rhs: Date) -> Bool {
    return lhs.compare(rhs) == ComparisonResult.orderedAscending
}

public func >(lhs: Date, rhs: Date) -> Bool {
    return lhs.compare(rhs) == ComparisonResult.orderedDescending
}
