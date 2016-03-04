//
//  ErrorOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 2/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

// Defines an object that stores en error which can be read to determine
// if its execution was successful.
protocol ErrorOperation: class {
    var error: NSError? { get }
}

protocol PrefetchedResultsOperation: class {
    var resultObjectIDs: [NSManagedObjectID]? { get }
}
