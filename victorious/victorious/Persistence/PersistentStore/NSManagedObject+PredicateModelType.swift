//
//  NSMangedObject+Predicates.swift
//  victorious
//
//  Created by Michael Sena on 1/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// An interface for dealing with classes that have a standard set of predicates.
protocol PredicateModelType: class {
    
    static var defaultPredicate: NSPredicate { get }
    
}
