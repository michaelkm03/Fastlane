//
//  PrefetchedResultsOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Defines an object that provides `NSManagedObjectID`s based on the
/// results of its execution so that subsequenct operations can check for
/// them and use them to fetch results faster from the persistent store.
protocol PrefetchedResultsOperation: class {
    var resultObjectIDs: [NSManagedObjectID]? { get }
}
