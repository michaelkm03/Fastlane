//
//  MockOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import Foundation
@testable import victorious

private let _testQueue = NSOperationQueue.mainQueue()

class MockOperation: NSOperation, Queuable {
    
    static var sharedQueue: NSOperationQueue {
        return _testQueue
    }
    
    var label: String = ""
    var operationBlock: ((MockOperation)->())? = nil
    
    override init() {
        super.init()
    }
    
    init( _ label: String, block:((MockOperation)->())? = nil ) {
        self.label = label
        self.operationBlock = block
    }
    
    func queueOn( queue: NSOperationQueue, completionBlock:((MockOperation)->())? ) {
        self.completionBlock = {
            completionBlock?( self )
        }
        queue.addOperation(self)
    }
    
    override func main() {
        self.operationBlock?(self)
    }
}
