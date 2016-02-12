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
    
    /// If a stream is pre populated with its stream items, no network request
    /// is needed and we just fetch those stream items locally
    func loadPreloadedStream(completion: ((NSError?)->())? ) {
        self.paginatedDataSource.refreshLocal(
            createOperation: {
                return StreamItemsFetcherOperation(streamObjectID: stream.objectID)
            },
            completion: { results in
                if results.count > 0 {
                    completion?(nil)
                } else {
                    completion?( NSError(domain: "StreamDataSource", code: -1, userInfo: nil) )
                }
        })
    }
    
    public func removeStreamItem(streamItem: VStreamItem) {
        RemoveStreamItemOperation(streamItemID: streamItem.remoteId).queue()
    }
}

extension VStreamCollectionViewDataSource: VPaginatedDataSourceDelegate {
    
    public func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        if suppressShelves {
            let filteredArray = (newValue.array as? [VStreamItem] ?? []).filter { $0.itemType == VStreamItemTypeShelf }
            self.visibleItems = NSOrderedSet(array: filteredArray)
        } else {
            self.visibleItems = newValue
        }
        self.delegate?.paginatedDataSource(paginatedDataSource, didUpdateVisibleItemsFrom: oldValue, to: self.visibleItems)
    }
    
    public func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: VDataSourceState, to newState: VDataSourceState) {
        self.delegate?.paginatedDataSource?(paginatedDataSource, didChangeStateFrom: oldState, to: newState)
    }
    
    func unloadStream() {
        self.paginatedDataSource.unload()
    }
}
