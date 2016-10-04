//
//  NSOperation.swift
//  victorious
//
//  Created by Jarod Long on 9/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension Operation {
    var dependentOperations: [Operation] {
        return Queue.allQueues.flatMap {
            $0.operations
        }.filter {
            $0.dependencies.contains(self)
        }
    }
}
