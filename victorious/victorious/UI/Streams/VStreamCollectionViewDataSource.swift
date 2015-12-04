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
        
        typealias OperationType = RequestOperation<StreamRequest>
        
        var operation: OperationType? = nil
        switch pageType {
        case .First:
            if let apiPath = self.stream?.apiPath {
                operation = StreamOperation(apiPath: apiPath)
            }
        case .Next:
            if let streamLoadOperation = self.streamLoadOperation as? OperationType {
                operation = streamLoadOperation.nextOperation()
            }
        case .Previous:
            if let streamLoadOperation = self.streamLoadOperation as? OperationType {
                operation = streamLoadOperation.previousOperation()
            }
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
            print( "operation = \(operation.dynamicType)" )
            self.streamLoadOperation = operation
        }
    }
}