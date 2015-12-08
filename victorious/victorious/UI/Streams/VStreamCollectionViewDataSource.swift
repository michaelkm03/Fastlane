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
        
        let nextOperation: StreamOperation?
        switch pageType {
        case .First:
            if let apiPath = self.stream?.apiPath  {
                nextOperation = StreamOperation(apiPath: (apiPath) )
            } else {
                nextOperation = nil
            }
        case .Next:
            nextOperation = self.streamLoadOperation?.next()
        case .Previous:
            nextOperation = self.streamLoadOperation?.prev()
        }
        
        if let operation = nextOperation {
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