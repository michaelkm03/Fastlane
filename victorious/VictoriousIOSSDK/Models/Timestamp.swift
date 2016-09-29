//
//  Timestamp.swift
//  victorious
//
//  Created by Jarod Long on 7/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A representation of an API-provided timestamp value.
public struct Timestamp: Comparable, CustomStringConvertible {
    
    // MARK: - Initializing
    
    /// Initialize with a timestamp string provided from a JSON payload.
    public init?(apiString: String) {
        guard let value = Int64(apiString) else {
            return nil
        }
        
        self.init(value: value)
    }
    
    /// Initialize with a millisecond integer value.
    public init(value: Int64) {
        self.value = value
    }
    
    /// Initialize with a date.
    public init(date: NSDate = NSDate()) {
        self.init(value: Int64(date.timeIntervalSince1970 * 1000.0))
    }
    
    // MARK: - Accessing the value
    
    /// The timestamp's millisecond integer value.
    ///
    /// This value must explicitly use a 64-bit integer because millisecond timestamps exceed 32-bit integer size.
    ///
    public var value: Int64
    
    /// The timestamp's value converted back to an API string.
    public var apiString: String {
        return "\(value)"
    }
    
    // MARK: - CustomStringConvertible
    
    public var description: String {
        return apiString
    }
    
    // MARK: - Constant values
    
    public static let max = Timestamp(value: Int64.max)
    public static let min = Timestamp(value: Int64.min)
    
    // MARK: - Compare
    
    public func within(threshold: Int64, of timeStamp: Timestamp) -> Bool {
        return abs(self.value - timeStamp.value) < threshold
    }
}

public func == (lhs: Timestamp, rhs: Timestamp) -> Bool {
    return lhs.value == rhs.value
}

public func < (lhs: Timestamp, rhs: Timestamp) -> Bool {
    return lhs.value < rhs.value
}

public extension Date {
    public init(timestamp: Timestamp) {
        self.init(timeIntervalSince1970: TimeInterval(timestamp.value) / 1000.0)
    }
}
