//
//  TimePaginatedDataSource.swift
//  victorious
//
//  Created by Jarod Long on 5/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

/// A protocol that items managed by `TimePaginatedDataSource` must conform to.
protocol PaginatableItem {
    var createdAt: Timestamp { get }
}

/// The different ways that paginated items can be loaded.
enum PaginatedLoadingType {
    /// Loads the newest page of items, replacing any existing items.
    case refresh
    
    /// Loads newer items, prepending them to the list.
    case newer
    
    /// Loads older items, appending them to the list.
    case older
}

/// An enum for expected ordering of paginated content.
enum PaginatedOrdering {
    case ascending, descending
}

/// An object that manages a paginated list of items retrieved from an operation using a time-based pagination system.
///
/// To use this object, you simply provide an API path with the appropriate pagination macros as well as an operation
/// that produces a list of items given a URL.
///
/// - REQUIRES: `Item` must conform to `PaginatableItem`. Swift doesn't allow us to specify that requirement, so
/// failing to conform will cause a runtime error.
///
/// - NOTE: This should be renamed to `PaginatedDataSource` once the other `PaginatedDataSource` is removed.
///
class TimePaginatedDataSource<Item, Operation: Queueable where Operation.CompletionBlockType == (newItems: [Item], stageEvent: ForumEvent?, error: NSError?) -> Void, Operation: NSOperation> {
    
    // MARK: - Initializing
    
    init(apiPath: APIPath, ordering: PaginatedOrdering = .descending, createOperation: (url: NSURL) -> Operation) {
        self.apiPath = apiPath
        self.ordering = ordering
        self.createOperation = createOperation
    }
    
    // MARK: - Configuration
    
    var apiPath: APIPath
    let ordering: PaginatedOrdering
    let createOperation: (url: NSURL) -> Operation
    private var currentOperation: Operation?
    
    // MARK: - Managing contents
    
    /// The data source's list of items ordered from oldest to newest.
    private(set) var items: [Item] = []
    
    /// Whether the data source is currently loading a page of items or not.
    var isLoading: Bool {
        return currentOperation != nil
    }
    
    /// Loads a new page of items.
    ///
    /// The `items` array will be updated automatically before `completion` is called.
    ///
    /// This method does nothing if a page is already being loaded.
    ///
    func loadItems(loadingType: PaginatedLoadingType, completion: ((newItems: [Item], stageEvent: ForumEvent?, error: NSError?) -> Void)? = nil) {
        if loadingType == .refresh {
            currentOperation?.cancel()
            currentOperation = nil
        }
        
        guard !isLoading else {
            return
        }
        
        guard let url = processedURL(for: loadingType) else {
            assertionFailure("Failed to construct a valid URL when loading a page in TimePaginatedDataSource.")
            return
        }
        
        currentOperation = createOperation(url: url)
        
        currentOperation?.queue { [weak self] newItems, stageEvent, error in
            defer {
                completion?(newItems: newItems, stageEvent: stageEvent, error: error)
            }
            
            guard let ordering = self?.ordering else {
                return
            }
            
            switch loadingType {
                case .refresh:
                    self?.items = newItems
                
                case .newer:
                    switch ordering {
                        case .descending: self?.prependItems(newItems)
                        case .ascending: self?.appendItems(newItems)
                    }
                
                case .older:
                    switch ordering {
                        case .descending: self?.appendItems(newItems)
                        case .ascending: self?.prependItems(newItems)
                    }
            }
            
            self?.currentOperation = nil
        }
    }
    
    private func prependItems(newItems: [Item]) {
        items = newItems + items
    }
    
    private func appendItems(newItems: [Item]) {
        items.appendContentsOf(newItems)
    }
    
    private func processedURL(for loadingType: PaginatedLoadingType) -> NSURL? {
        let (fromTime, toTime) = paginationTimestamps(for: loadingType)
        
        // The from-time should always come after the to-time.
        guard fromTime > toTime else {
            assertionFailure("Generated invalid pagination timestamps.")
            return nil
        }
        
        apiPath.macroReplacements["%%FROM_TIME%%"] = "\(fromTime)"
        apiPath.macroReplacements["%%TO_TIME%%"] = "\(toTime)"
        
        return apiPath.url
    }
    
    /// Returns the range of timestamps needed to load new content for `loadingType`.
    ///
    /// - NOTE: `fromTime` will always be greater than `toTime` to match the API's pagination conventions.
    ///
    private func paginationTimestamps(for loadingType: PaginatedLoadingType) -> (fromTime: Int64, toTime: Int64) {
        let now = NSDate().millisecondsSince1970
        
        switch loadingType {
            case .refresh: return (fromTime: now, toTime: 0)
            case .newer: return (fromTime: now, toTime: newestTimestamp ?? 0)
            case .older: return (fromTime: oldestTimestamp ?? now, toTime: 0)
        }
    }
    
    // NOTE: Pagination timestamps are inclusive, so to avoid retrieving multiple copies of the same item, we adjust
    // the timestamps by 1ms to make them exclusive.
    
    private var oldestTimestamp: Int64? {
        if let timestamp = items.reduce(nil, combine: { timestamp, item in
            min(timestamp ?? Int64.max, (item as! PaginatableItem).createdAt.value)
        }) {
            return timestamp - 1
        }
        
        return nil
    }
    
    private var newestTimestamp: Int64? {
        if let timestamp = items.reduce(nil, combine: { timestamp, item in
            max(timestamp ?? 0, (item as! PaginatableItem).createdAt.value)
        }) {
            return timestamp + 1
        }
        
        return nil
    }
}
