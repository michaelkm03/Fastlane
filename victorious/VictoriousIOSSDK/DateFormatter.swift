//
//  DateFormatter.swift
//  victorious
//
//  Created by Patrick Lynch on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class DateFormatter {
    private static let formattersCache = NSCache()
    
    enum Format: String {
        case VictoriousStandard = "yyyy-MM-dd HH:mm:ss"
    }
    
    func dateFromString( string: String, format: Format = .VictoriousStandard ) -> NSDate? {
        let dateFormatter: NSDateFormatter
        if let existing = DateFormatter.formattersCache.objectForKey(format.rawValue) as? NSDateFormatter {
            dateFormatter = existing
        } else {
            let newFormatter = NSDateFormatter()
            newFormatter.dateFormat = format.rawValue
            DateFormatter.formattersCache.setObject(newFormatter, forKey: format.rawValue)
            dateFormatter = newFormatter
        }
        return dateFormatter.dateFromString( string )
    }
}