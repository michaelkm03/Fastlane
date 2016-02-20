//
//  VStreamCollectionViewDataSource+Networking.swift
//  victorious
//
//  Created by Patrick Lynch on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

extension VStreamCollectionViewDataSource {
    
    /// The primary way to load a stream.
    ///
    /// -parameter pageType Which page of this paginatined method should be loaded (see VPageType).
    func loadPage( pageType: VPageType, completion:(NSError?)->()) {
        guard let apiPath = stream.apiPath else {
            completion(NSError(domain: "StreamLoadingError", code: 1, userInfo: nil))
            return
        }
        self.paginatedDataSource.loadPage( pageType,
            createOperation: {
                return StreamOperation(apiPath: apiPath)
            },
            completion: { (operation, error) in
                completion(error)
            }
        )
    }
    
    /// If a stream is pre populated with its stream items, no network request
    /// is needed and we just fetch those stream items locally
    func loadPreloadedStream(completion: ((NSError?)->())? ) {
        self.paginatedDataSource.loadPage( VPageType.First,
            createOperation: {
                return StreamOperation(apiPath: stream.apiPath ?? "", sequenceID: nil, existingStreamID: stream.objectID)
            },
            completion: { (operation, error) in
                completion?(error)
        })
    }
    
    func removeDeletedItems() {
        self.paginatedDataSource.removeDeletedItems()
    }
    
    func unloadStream() {
        self.paginatedDataSource.unload()
    }
}

extension VStreamCollectionViewDataSource: VPaginatedDataSourceDelegate {
    
    public func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        var filteredOldItems = oldValue
        
        if suppressShelves {
            filteredOldItems = streamItemsWithoutShelves(oldValue.array as? [VStreamItem] ?? [])
            visibleItems = streamItemsWithoutShelves(newValue.array as? [VStreamItem] ?? [])
        } else {
            visibleItems = newValue
        }
        
        delegate?.paginatedDataSource(paginatedDataSource, didUpdateVisibleItemsFrom: filteredOldItems, to: visibleItems)
    }
    
    public func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: VDataSourceState, to newState: VDataSourceState) {
        delegate?.paginatedDataSource?(paginatedDataSource, didChangeStateFrom: oldState, to: newState)
    }
    
    public func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didReceiveError error: NSError) {
        self.delegate?.paginatedDataSource(paginatedDataSource, didReceiveError: error)
    }
}
