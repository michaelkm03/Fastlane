//
//  PersistenceParsable.swift
//  victorious
//
//  Created by Patrick Lynch on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

protocol PersistenceParsable {
    
    /// The generic type which is the source of data from which to populate the receiver
    associatedtype SourceModelType
    
    /// Populates data on the receiver
    ///
    /// - paarameter model An object that is the source of data from which to populate the receiver
    /// - parameter dataStore An object that provides access to the persistent store so that new objects
    ///   may be created or existing objects retrieved during serialization
    func populate( fromSourceModel sourceModel: SourceModelType )
}
