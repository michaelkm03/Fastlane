//
//  Dictionary+Union.swift
//  victorious
//
//  Created by Patrick Lynch on 3/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func vsdk_unionInPlace<S: SequenceType where S.Generator.Element == (Key,Value)>(sequence: S) {
        for (key, value) in sequence {
            self[key] = value
        }
    }
}