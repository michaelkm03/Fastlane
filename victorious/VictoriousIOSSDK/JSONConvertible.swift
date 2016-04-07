//
//  JSONConvertible.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/**
 *  This protocol defines that the implementor will be able to return a JSON representation of itself.
 */
public protocol JSONConvertable {
    /**
     Should return a JSON representation of the instance.
     
     - returns: A JSON instance.
     */
    func toJSON() -> JSON
}
