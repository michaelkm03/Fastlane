//
//  VStreamCollectionViewDataSource+Networking.swift
//  victorious
//
//  Created by Patrick Lynch on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

public extension VStreamCollectionViewDataSource {
    
    /// The primary way to load a stream.
    ///
    /// -parameter pageType Which page of this paginatined method should be loaded (see VPageType).
    public func loadPage( pageType: VPageType, withSuccess success:()->(), failure:(NSError?)->()) {
        
        if  self.streamLoadOperation == nil, let apiPath = self.stream?.apiPath {
            self.streamLoadOperation = StreamOperation(apiPath: apiPath)
        }
        else if let streamLoadOperation = self.streamLoadOperation as? StreamOperation,
            let operation: StreamOperation = streamLoadOperation.nextOperation() {
                self.streamLoadOperation = operation
        }
        
        if let operation = self.streamLoadOperation as? StreamOperation {
            self.isLoading = true
            operation.queue() { error in
                self.isLoading = false
                if let error = error {
                    failure( error )
                } else {
                    success()
                }
            }
        }
    }
}