//
//  Dictionary+Union.swift
//  victorious
//
//  Created by Patrick Lynch on 3/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func vsdk_unionInPlace(dictionary: Dictionary<Key, Value>) {
        for (key, value) in dictionary {
            self[key] = value
        }
    }
}
