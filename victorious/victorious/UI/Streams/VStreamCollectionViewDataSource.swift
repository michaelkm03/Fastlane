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
    
    ///The primary way to load a stream.
    ///
    /// -parameter pageType Which page of this paginatined method should be loaded (see VPageType).
    public func loadPage( pageType: VPageType, withSuccess success:()->(), failure:(NSError?)->()) {
        
        guard let apiPath = self.stream?.apiPath else {
            fatalError( "Bad API path" )
        }
        
        let operation: StreamOperation?
        switch pageType {
        case .First:
            operation = StreamOperation(apiPath: apiPath, sequenceID: nil)
        case .Next:
            operation = (self.streamLoadOperation as? StreamOperation)?.nextPageOperation
        case .Previous:
            operation = (self.streamLoadOperation as? StreamOperation)?.previousPageOperation
        }
        
        if let currentOperation = operation {
            self.isLoading = true
            currentOperation.queue() { error in
                self.isLoading = false
                if let error = error {
                    failure( error )
                } else {
                    success()
                }
            }
            self.streamLoadOperation = currentOperation
        }
    }
    
    /// Returns whether or not there is a nother page to load, i.e. we are not already at the end of the stream.
    func canLoadNextPage() -> Bool {
        return (self.streamLoadOperation as? StreamOperation)?.nextPageOperation != nil
    }
}
