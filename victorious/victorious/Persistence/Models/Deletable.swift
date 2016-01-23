//
//  Deletable.swift
//  victorious
//
//  Created by Michael Sena on 1/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Conforming classes can be flagged for deletion.
protocol Deletable: class {

    var markedForDeletion: Bool { get set }
    
    static var markedForDeletionPredicate: NSPredicate{get}
    static var notMarkedForDeletionPredicate: NSPredicate{get}
}