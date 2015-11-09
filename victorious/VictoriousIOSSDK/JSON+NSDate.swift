//
//  JSON+NSDate.swift
//  victorious
//
//  Created by Patrick Lynch on 11/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON {
    
    static var dateFormatter: NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
    
    public var date: NSDate? {
        get {
            switch self.type {
            case .String:
                if let string = self.object as? String {
                    return JSON.dateFormatter.dateFromString(string)
                }
                return nil
            default:
                return nil
            }
        }
        set {
            if let date = newValue {
                self.object = JSON.dateFormatter.stringFromDate( date )
            } else {
                self.object = NSNull()
            }
        }
    }
}