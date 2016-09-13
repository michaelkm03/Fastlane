//
//  TempDirectoryCleanupOperation.swift
//  victorious
//
//  Created by Vincent Ho on 3/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class TempDirectoryCleanupOperation: SyncOperation<Void> {
    enum Error: ErrorType {
        case NoFileFoundInTempDirectory
    }
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute() -> OperationResult<Void> {
        guard let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(kContentCreationDirectory) else {
            return .failure(Error.NoFileFoundInTempDirectory)
        }
        let fileManager = NSFileManager.defaultManager()
        let _ = try? fileManager.removeItemAtURL(url)
        return .success()
    }
}
