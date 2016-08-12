//
//  TempDirectoryCleanupOperation.swift
//  victorious
//
//  Created by Vincent Ho on 3/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class TempDirectoryCleanupOperation: BackgroundOperation {
    
    override func start() {
        beganExecuting()
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(kContentCreationDirectory)
            let fileManager = NSFileManager.defaultManager()

            if let url = url {
                let _ = try? fileManager.removeItemAtURL(url)
            }

            self.finishedExecuting()
        }
    }
}
