//
//  NSDate+Milliseconds.swift
//  victorious
//
//  Created by Sebastian Nystorm on 2/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension NSDate {
    /// Initialize with an API-provided timestamp value.
    public convenience init?(timestamp: String) {
        guard let timestampValue = Int64(timestamp) else {
            return nil
        }
        
        self.init(millisecondsSince1970: timestampValue)
    }
    
    /// Initialize with the given number of milliseconds since 1970.
    public convenience init(millisecondsSince1970: Int64) {
        self.init(timeIntervalSince1970: NSTimeInterval(millisecondsSince1970 / 1000))
    }
    
    /// The date's value in API timestamp format.
    public var timestamp: String {
        return "\(millisecondsSince1970)"
    }
    
    /// The number of milliseconds between 1970 and this date.
    public var millisecondsSince1970: Int64 {
        return Int64(timeIntervalSince1970 * 1000.0)
    }
}
