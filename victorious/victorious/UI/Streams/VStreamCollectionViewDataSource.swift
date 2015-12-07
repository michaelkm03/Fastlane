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
        
        let operation: StreamOperation?
        if let apiPath = self.stream?.apiPath where pageType == .First {
            operation = StreamOperation(apiPath: apiPath)
        } else {
            operation = self.streamLoadOperation?.operation(forPageType: pageType)
        }
        
        if let operation = operation {
            self.isLoading = true
            operation.queue() { error in
                self.isLoading = false
                if let error = error {
                    failure( error )
                } else {
                    success()
                }
            }
            self.streamLoadOperation = operation
        }
    }
}