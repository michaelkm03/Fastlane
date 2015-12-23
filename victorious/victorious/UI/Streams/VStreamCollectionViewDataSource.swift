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
    public func loadPage( pageType: VPageType, completion:(NSError?)->()) {
        guard let apiPath = self.stream.apiPath else {
            return
        }
        
        self.paginatedDataSource.loadPage( pageType,
            createOperation: {
                return StreamOperation(apiPath: apiPath)
            },
            completion: { (operation, error) in
                if let error = error {
                    completion( error )
                
                } else {
                    completion( nil )
                }
            }
        )
    }
    
    public func removeStreamItem(streamItem: VStreamItem) {
        RemoteStreamItemOperation(streamItemID: streamItem.remoteId).queueOn( RequestOperation.sharedQueue )
    }
    
    public func unloadStream() {
        UnloadStreamItemOperation(streamID: self.stream.remoteId ).queueOn( RequestOperation.sharedQueue )
    }
}