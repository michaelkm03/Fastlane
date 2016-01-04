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
/// references madea vailable by static property `v_defaultDateFormatter`.
private let _sharedDefaultDateFormatter = NSDateFormatter(v_format: .Standard)

public extension NSDateFormatter {
    
    public static var v_defaultDateFormatter: NSDateFormatter {
        return _sharedDefaultDateFormatter
    }
    
    public convenience init( v_format format: DateFormat ) {
        self.init()
        self.dateFormat = format.rawValue
    }
}
