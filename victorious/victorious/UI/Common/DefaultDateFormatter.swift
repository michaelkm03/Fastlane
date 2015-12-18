//
//  DefaultDateFormatter.swift
//  victorious
//
//  Created by Patrick Lynch on 12/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Defines the default date formatter for this application.  Most uses of date formatter
/// will want to use this class.  If you wish to customize the date format differently,
/// please create your own NSDateFormatter.
@objc class DefaultDateFormatter: NSDateFormatter {
    
    override init() {
        super.init()
        
        self.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        self.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
