//
//  TempDirectoryCleanupOperation.swift
//  victorious
//
//  Created by Vincent Ho on 3/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class TempDirectoryCleanupOperation: BackgroundOperation {
    
    override func main() {
        let URL = NSURL(fileURLWithPath: "\(NSTemporaryDirectory())")
        let fileManager = NSFileManager.defaultManager()
        let _ = try? fileManager.removeItemAtURL(URL)
    }
}
