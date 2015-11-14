//
//  Bool+Initializers.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public extension Bool {
    init?( _ string: String ) {
        let lowercaseString = string.lowercaseString
        if ["true", "yes"].contains( lowercaseString ) {
            self.init(true)
        } else if ["false", "no"].contains( lowercaseString ) {
            self.init(false)
        } else {
            return nil
        }
    }
    
    init?<T : IntegerType>( _ integer: T) {
        if integer == 1 {
            self.init(true)
        } else if integer == 0 {
            self.init(false)
        } else {
            return nil
        }
    }
}
