//
//  DictionaryConvertible.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public protocol DictionaryConvertible {
    
    /// A preferred key to use when serializing into a parent dictionary.
    var defaultKey: String { get }
    
    /// Return a dictionary representation of itself.
    func toDictionary() -> [String: AnyObject]
}
