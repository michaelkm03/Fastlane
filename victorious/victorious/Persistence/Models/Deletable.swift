//
//  Deletable.swift
//  victorious
//
//  Created by Michael Sena on 1/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Conforming classes can be marked for deletion in a two-phase process.
/// This is to assist calling code of the persistence layer which may be
/// retaining a `Deletable` class.
protocol Deletable: class {

    var markedForDeletion: Bool { get set }
    
    /// When an object has been marked for deletion this predicate should evaluate to true
    static var markedForDeletionPredicate: NSPredicate{ get }
    
    /// When an object has *not* been marked for deletion this predicate should evaluate to true
    static var notMarkedForDeletionPredicate: NSPredicate{ get }
}