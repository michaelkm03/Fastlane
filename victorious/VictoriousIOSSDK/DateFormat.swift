//
//  DateFormat.swift
//  victorious
//
//  Created by Michael Sena on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public enum DateFormat: String {
    case Standard = "yyyy-MM-dd HH:mm:ss"
}

extension NSDateFormatter {
    
    public convenience init( format: DateFormat ) {
        self.init()
        self.dateFormat = format.rawValue
    }
}
