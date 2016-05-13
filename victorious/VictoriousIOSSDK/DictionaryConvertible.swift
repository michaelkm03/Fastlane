//
//  DictionaryConvertible.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public protocol DictionaryConvertible {
    
    /// Key for root object when serializing into a parent dictionary.
    var rootKey: String { get }

    /// The key for the root type node key, might be nil which means there is no type value associated at the root.
    var rootTypeKey: String? { get }

    /// The value of the root node type, might be nil which means there is no type value associated at the root.
    var rootTypeValue: String? { get }

    /// Return a dictionary representation of itself.
    func toDictionary() -> [String: AnyObject]
}
