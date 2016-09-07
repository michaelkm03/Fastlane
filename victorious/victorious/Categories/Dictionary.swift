//
//  Dictionary.swift
//  victorious
//
//  Created by Mariana Lenetis on 9/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension Dictionary {
    // Combines two dictionaries, favors passed in value in case of key collision
    mutating func unionInPlace(dictionary: Dictionary) {
        for (key, value) in dictionary {
            self[key] = value
        }
    }
}