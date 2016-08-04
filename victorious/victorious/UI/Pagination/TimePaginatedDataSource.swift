//
//  TimePaginatedDataSource.swift
//  victorious
//
//  Created by Jarod Long on 5/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

/// A protocol that items managed by `TimePaginatedDataSource` must conform to.
protocol PaginatableItem {
    /// The timestamp that pagination logic will be performed with.
    var paginationTimestamp: Timestamp { get }
}

/// An enum for expected ordering of paginated content.
enum PaginatedOrdering {
    /// New items will be appended to the end of a `TimePaginatedDataSource`'s `items`.
    case ascending
    
    /// New items will be prepended to the end of a `TimePaginatedDataSource`'s `items`.
    case descending
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
    
    init(apiPath: APIPath, ordering: PaginatedOrdering = .descending, throttleTime: NSTimeInterval = 1.0, createOperation: (url: NSURL) -> Operation) {
        self.apiPath = apiPath
        self.ordering = ordering
        self.throttleTime = throttleTime
        self.createOperation = createOperation
    }
    
    // MARK: - Configuration
    
    /// The path to the resource that will be paginated. Must contain the appropriate pagination substitution macros.
    var apiPath: APIPath {
        didSet {
            // Switching API paths means we have a new set of content, so older items are now potentially available
            // again. If we don't reset this, we can get into a state where we prematurely stop loading older items.
            olderItemsAreAvailable = true
        }
    }
    
    /// The expected ordering of the items managed by the data source.
    let ordering: PaginatedOrdering
    
    /// The minimum time between requests for item loading.
    let throttleTime: NSTimeInterval
    
    /// A function that converts a URL into an operation that loads a page of items.
    let createOperation: (url: NSURL) -> Operation
    
    /// The operation that is currently loading items, if any.
    private var currentOperation: Operation?
    
    // MARK: - Managing contents
    
    /// The data source's list of items ordered from oldest to newest.
    private(set) var items: [Item] = []
    
    /// Whether the data source is currently loading a page of items or not.
    var isLoading: Bool {
        return (currentOperation?.cancelled == false)
    }
    
    /// Whether the data source has determined that additional older items are available or not.
    ///
    /// The data source will set this to false once it requests an older page and receives no items.
    ///
    private(set) var olderItemsAreAvailable = true
    
    /// The time that items were last requested.
    private var lastLoadTime: NSDate?
    
    /// Whether the `lastLoadTime` was recent enough that we should throttle item loading.
    private var shouldThrottle: Bool {
        guard let lastLoadTime = lastLoadTime else {
            return false
        }
        
        return fabs(lastLoadTime.timeIntervalSinceNow) < throttleTime
    }
    
    /// Whether the data source is in a state that should allow loading items for the given `loadingType`.
    private func shouldLoadItems(for loadingType: PaginatedLoadingType) -> Bool {
        guard !isLoading else {
            return false
        }
        
        switch loadingType {
            case .newer: return !shouldThrottle
            case .older: return olderItemsAreAvailable && !shouldThrottle
            case .refresh: return true
        }
    }
    
    /// Loads a new page of items.
    ///
    /// The `items` array will be updated automatically before `completion` is called.
    ///
    /// - RETURNS: Whether or not items were actually requested to be loaded. Items will not be loaded if a page is
    /// already being loaded, or if loading is being throttled.
    ///
    func loadItems(loadingType: PaginatedLoadingType, completion: ((newItems: [Item], stageEvent: ForumEvent?, error: NSError?) -> Void)? = nil) -> Bool {
        if loadingType == .refresh {
            currentOperation?.cancel()
            currentOperation = nil
        }
        
        guard shouldLoadItems(for: loadingType) else {
            return false
        }
        
        guard let url = processedURL(for: loadingType) else {
            assertionFailure("Failed to construct a valid URL when loading a page in TimePaginatedDataSource.")
            return false
        }
        
        lastLoadTime = NSDate()
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
                    if newItems.count == 0 && error == nil {
                        self?.olderItemsAreAvailable = false
                    }
                    
                    switch ordering {
                        case .descending: self?.appendItems(newItems)
                        case .ascending: self?.prependItems(newItems)
                    }
            }
            
            self?.currentOperation = nil
        }
        
        return true
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
    private func paginationTimestamps(for loadingType: PaginatedLoadingType) -> (fromTime: Timestamp, toTime: Timestamp) {
        let now = Timestamp()
        
        switch loadingType {
            case .refresh: return (fromTime: now, toTime: Timestamp(value: 0))
            case .newer: return (fromTime: now, toTime: newestTimestamp ?? Timestamp(value: 0))
            case .older: return (fromTime: oldestTimestamp ?? now, toTime: Timestamp(value: 0))
        }
    }
    
    // NOTE: Pagination timestamps are inclusive, so to avoid retrieving multiple copies of the same item, we adjust
    // the timestamps by 1ms to make them exclusive.
    
    private var oldestTimestamp: Timestamp? {
        if let timestamp: Timestamp = items.reduce(nil, combine: { timestamp, item in
            return min(timestamp ?? Timestamp.max, (item as! PaginatableItem).paginationTimestamp)
        }) {
            return Timestamp(value: timestamp.value - 1)
        }
        
        return nil
    }
    
    private var newestTimestamp: Timestamp? {
        if let timestamp: Timestamp = items.reduce(nil, combine: { timestamp, item in
            return max(timestamp ?? Timestamp(value: 0), (item as! PaginatableItem).paginationTimestamp)
        }) {
            return Timestamp(value: timestamp.value + 1)
        }
        
        return nil
    }
}
