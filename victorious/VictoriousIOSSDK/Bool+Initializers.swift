//
//  Bool+Initializers.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

extension Bool {
    init?(_ string: String) {
        let lowercaseString = string.lowercased()
        
        if ["true", "yes"].contains(lowercaseString) {
            self.init(true)
        }
        else if ["false", "no"].contains(lowercaseString) {
            self.init(false)
        }
        else {
            return nil
        }
    }
    
    init?<T : Integer>(_ integer: T) {
        if integer == 1 {
            self.init(true)
        }
        else if integer == 0 {
            self.init(false)
        }
        else {
            return nil
        }
    }
}

extension JSON {
    /// Optional bool or optional bool unwrapped and casted from integer or string
    var v_boolFromAnyValue: Bool? {
        if let integer = self.int {
            return Bool(integer)
        }
        else if let string = self.string {
            return Bool(string)
        }
        else {
            return self.bool
        }
    }
}
