//
//  Serializable.swift
//  VictoriousIOSSDK
//
//  Created by Patrick Lynch on 10/26/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation

enum PersistenceError: ErrorType {
    case FailedToSave
    case MissingRequiredData
}

/// Defines an object that can be populated from a generic type.
public protocol Serializable  {
    
    /// The generic type which is the source of data from which to populate the receiver
    typealias ModelType
    
    /// Populates data on the receiver
    ///
    /// - paarameter model An object that is the source of data from which to populate the receiver
    /// - parameter dataStore An object that provides access to the persistent store so that new objects
    ///   may be created or existing objects retrieved during serialization
    func serialize( model: ModelType, dataStore: DataStore )
    
    /// Creates a ModelType instance that represents that data of the receiver
    func deserialize() -> ModelType
}

public extension Serializable {
    
    func deserialize() -> ModelType {
        fatalError( "Cannot deserialize object of type \(self.dynamicType).  Implemented a `desererialize()` method to allow this." )
    }
}