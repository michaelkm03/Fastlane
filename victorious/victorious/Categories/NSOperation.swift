//
//  NSOperation.swift
//  victorious
//
//  Created by Jarod Long on 9/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension NSOperation {
    var dependentOperations: [NSOperation] {
        return Queue.allQueues.flatMap {
            $0.operations
        }.filter {
            $0.dependencies.contains(self)
        }
    }
}
