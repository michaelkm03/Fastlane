//
//  TempDirectoryCleanupOperation.swift
//  victorious
//
//  Created by Vincent Ho on 3/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class TempDirectoryCleanupOperation: SyncOperation<Void> {
    enum Errors: Error {
        case noFileFoundInTempDirectory
    }
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute() -> OperationResult<Void> {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(kContentCreationDirectory)
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: url)
        }
        catch {
            return .failure(Errors.noFileFoundInTempDirectory)
        }
        
        return .success()
    }
}
