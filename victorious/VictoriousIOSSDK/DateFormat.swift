//
//  DateFormat.swift
//  victorious
//
//  Created by Patrick Lynch on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public enum DateFormat: String {
    case Standard = "yyyy-MM-dd HH:mm:ss"
}

/// Specify the standard default data formatter here, to be shared and
/// references madea vailable by static property `vsdk_defaultDateFormatter`.
private let _sharedDefaultDateFormatter = DateFormatter(vsdk_format: .Standard)

public extension DateFormatter {
    
    public class func vsdk_defaultDateFormatter() -> DateFormatter {
        return _sharedDefaultDateFormatter
    }
    
    public convenience init( vsdk_format format: DateFormat ) {
        self.init()
        
        dateFormat = format.rawValue
        locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone!
    }
}
