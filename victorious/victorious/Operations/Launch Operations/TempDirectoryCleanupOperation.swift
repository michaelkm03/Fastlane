//
//  TempDirectoryCleanupOperation.swift
//  victorious
//
//  Created by Vincent Ho on 3/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class TempDirectoryCleanupOperation: SyncOperation<Void> {
    
    override var executionQueue: NSOperationQueue {
        return .v_globalBackgroundQueue
    }
    
    override func execute() -> OperationResult<Void> {
        let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(kContentCreationDirectory)
        let fileManager = NSFileManager.defaultManager()
        let _ = try? fileManager.removeItemAtURL(url)
        return .success()
    }
}
