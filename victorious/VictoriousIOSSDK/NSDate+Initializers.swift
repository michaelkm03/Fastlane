//
//  NSDate+Initializers.swift
//  victorious
//
//  Created by Sebastian Nystorm on 2/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension NSDate {
    public convenience init(millisecondsSince1970 milliseconds: Double) {
        self.init(timeIntervalSince1970: milliseconds / 1000)
    }
}
