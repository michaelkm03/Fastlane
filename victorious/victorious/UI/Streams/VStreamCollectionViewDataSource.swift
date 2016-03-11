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
            completion: { (results, error, cancelled) in
                completion(error)
            }
        )
    }
    
    /// If a stream is pre populated with its stream items, no network request
    /// is needed and we just fetch those stream items locally
    func loadPreloadedStreamWithCompletion(completion: ((NSError?)->())? ) {
        self.paginatedDataSource.loadPage( VPageType.First,
            createOperation: {
                // For a preloaded stream, if the `stream` has an apiPath, we need to pass it in so that
                // the preloaded stream has a valid apiPath to load next page.
                // e.g. Explore recent feed
                return StreamOperation(apiPath: stream.apiPath ?? "", sequenceID: nil, existingStreamID: stream.objectID)
            },
            completion: { (results, error, cancelled) in
                completion?(error)
        })
    }
    
    func removeDeletedItems() {
        self.paginatedDataSource.removeDeletedItems()
    }
    
    func unload() {
        self.paginatedDataSource.unload()
    }
}

extension VStreamCollectionViewDataSource: VPaginatedDataSourceDelegate {
    
    public func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        var filteredOldItems = oldValue
        
        if suppressShelves {
            filteredOldItems = oldValue.v_orderedSetFilteredWithoutShelves()
            visibleItems = newValue.v_orderedSetFilteredWithoutShelves()
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

private extension NSOrderedSet {
    
    func v_orderedSetFilteredWithoutShelves() -> NSOrderedSet {
        let predicate = NSPredicate() { (item, _) -> Bool in
            if item is VStreamItem {
                return item.itemType != VStreamItemTypeShelf
            } else {
                return false
            }
        }
        return self.filteredOrderedSetUsingPredicate(predicate)
    }
}
