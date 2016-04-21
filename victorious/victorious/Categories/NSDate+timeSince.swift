//
//  NSDate+timeSince.swift
//  victorious
//
//  Created by Jarod Long on 4/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

@objc enum DateTimeIntervalStringFormat: Int {
    case concise, verbose
}

@objc enum DateTimeIntervalStringPrecision: Int {
    case minutes, seconds
}

extension NSDate {
    // Avoiding default values for the format parameter for Objective-C compatibility.
    
    func stringDescribingTimeIntervalSinceNow() -> String {
        return stringDescribingTimeIntervalSinceNow(format: .concise, precision: .minutes)
    }
    
    func stringDescribingTimeIntervalSinceNow(format format: DateTimeIntervalStringFormat, precision: DateTimeIntervalStringPrecision) -> String {
        return stringDescribingTimeIntervalSince(NSDate(), format: format, precision: precision)
    }
    
    func stringDescribingTimeIntervalSince(date: NSDate) -> String {
        return stringDescribingTimeIntervalSince(date, format: .concise, precision: .minutes)
    }
    
    func stringDescribingTimeIntervalSince(date: NSDate, format: DateTimeIntervalStringFormat, precision: DateTimeIntervalStringPrecision) -> String {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .WeekOfMonth, .Day, .Hour, .Minute, .Second], fromDate: self, toDate: date, options: [])
        
        switch components {
        case let components where components.year > 1:
            switch format {
            case .concise:
                return NSString(format: NSLocalizedString("YearsAgo", comment: ""), components.year) as String
            case .verbose:
                return NSString(format: NSLocalizedString("YearsAgo Verbose", comment: ""), components.year) as String
            }
        
        case let components where components.year == 1:
            switch format {
            case .concise:
                return NSLocalizedString("LastYear", comment: "")
            case .verbose:
                return NSLocalizedString("LastYear Verbose", comment: "")
            }
        
        case let components where components.month > 1:
            switch format {
            case .concise:
                return NSString(format: NSLocalizedString("MonthsAgo", comment: ""), components.month) as String
            case .verbose:
                return NSString(format: NSLocalizedString("MonthsAgo Verbose", comment: ""), components.month) as String
            }
        
        case let components where components.month == 1:
            switch format {
            case .concise:
                return NSLocalizedString("LastMonth", comment: "")
            case .verbose:
                return NSLocalizedString("LastMonth Verbose", comment: "")
            }
        
        case let components where components.weekOfMonth > 1:
            switch format {
            case .concise:
                return NSString(format: NSLocalizedString("WeeksAgo", comment: ""), components.weekOfMonth) as String
            case .verbose:
                return NSString(format: NSLocalizedString("WeeksAgo Verbose", comment: ""), components.weekOfMonth) as String
            }
        
        case let components where components.weekOfMonth == 1:
            switch format {
            case .concise:
                return NSLocalizedString("LastWeek", comment: "")
            case .verbose:
                return NSLocalizedString("LastWeek Verbose", comment: "")
            }
        
        case let components where components.day > 1:
            switch format {
            case .concise:
                return NSString(format: NSLocalizedString("DaysAgo", comment: ""), components.day) as String
            case .verbose:
                return NSString(format: NSLocalizedString("DaysAgo Verbose", comment: ""), components.day) as String
            }
        
        case let components where components.day == 1:
            switch format {
            case .concise:
                return NSLocalizedString("Yesterday", comment: "")
            case .verbose:
                return NSLocalizedString("Yesterday Verbose", comment: "")
            }
        
        case let components where components.hour > 1:
            switch format {
            case .concise:
                return NSString(format: NSLocalizedString("HoursAgo", comment: ""), components.hour) as String
            case .verbose:
                return NSString(format: NSLocalizedString("HoursAgo Verbose", comment: ""), components.hour) as String
            }
        
        case let components where components.hour == 1:
            switch format {
            case .concise:
                return NSLocalizedString("HourAgo", comment: "")
            case .verbose:
                return NSLocalizedString("HourAgo Verbose", comment: "")
            }
        
        case let components where components.minute > 1:
            switch format {
            case .concise:
                return NSString(format: NSLocalizedString("MinutesAgo", comment: ""), components.minute) as String
            case .verbose:
                return NSString(format: NSLocalizedString("MinutesAgo Verbose", comment: ""), components.minute) as String
            }
        
        case let components where components.minute == 1:
            switch format {
            case .concise:
                return NSLocalizedString("MinuteAgo", comment: "")
            case .verbose:
                return NSLocalizedString("MinuteAgo Verbose", comment: "")
            }
        
        case let components where components.second > 1 && precision == .seconds:
            switch format {
            case .concise:
                return NSString(format: NSLocalizedString("SecondsAgo", comment: ""), components.second) as String
            case .verbose:
                return NSString(format: NSLocalizedString("SecondsAgo Verbose", comment: ""), components.second) as String
            }
        
        case let components where components.second == 1 && precision == .seconds:
            switch format {
            case .concise:
                return NSLocalizedString("SecondAgo", comment: "")
            case .verbose:
                return NSLocalizedString("SecondAgo Verbose", comment: "")
            }
        
        default:
            return NSLocalizedString("Now", comment: "")
        }
    }
}
