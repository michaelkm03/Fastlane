//
//  TimePaginatedDataSource.swift
//  victorious
//
//  Created by Jarod Long on 5/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

/// A protocol that items managed by `TimePaginatedDataSource` must conform to.
protocol PaginatableItem {
    var createdAt: NSDate { get }
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
class TimePaginatedDataSource<Item, Operation: Queueable where Operation.CompletionBlockType == (newItems: [Item], error: NSError?) -> Void> {
    // MARK: - Initializing
    
    init(apiPath: APIPath, createOperation: (url: NSURL) -> Operation) {
        self.apiPath = apiPath
        self.createOperation = createOperation
    }
    
    // MARK: - Configuration
    
    private(set) var apiPath: APIPath
    
    let createOperation: (url: NSURL) -> Operation
    
    // MARK: - Managing content
    
    /// The data source's list of items ordered from oldest to newest.
    private(set) var items: [Item] = []
    
    /// Whether the data source is currently loading a page of items or not.
    private(set) var isLoading = false
    
    /// Loads a new page of items.
    ///
    /// The `items` array will be updated automatically before `completion` is called.
    ///
    /// This method does nothing if a page is already being loaded.
    ///
    func loadItems(loadingType: PaginatedLoadingType, completion: ((newItems: [Item], error: NSError?) -> Void)? = nil) {
        guard !isLoading else {
            return
        }
        
        guard let url = processedURL(for: loadingType) else {
            assertionFailure("Failed to construct a valid URL when loading a page in TimePaginatedDataSource.")
            return
        }
        
        isLoading = true
        
        if loadingType == .refresh {
            items = []
        }
        
        createOperation(url: url).queue { [weak self] newItems, error in
            switch loadingType {
                case .refresh: self?.items = newItems
                case .newer:   self?.items = newItems + (self?.items ?? [])
                case .older:   self?.items.appendContentsOf(newItems)
            }
            
            self?.isLoading = false
            
            completion?(newItems: newItems, error: error)
        }
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
    
    private func paginationTimestamps(for loadingType: PaginatedLoadingType) -> (fromTime: Int64, toTime: Int64) {
        let now = NSDate().paginationTimestamp
        
        switch loadingType {
        case .refresh, .newer:
            return (fromTime: now, toTime: newestTimestamp ?? 0)
        case .older:
            return (fromTime: oldestTimestamp ?? now, toTime: 0)
        }
    }
    
    // NOTE: Pagination timestamps are inclusive, so to avoid retrieving multiple copies of the same item, we adjust
    // the timestamps by 1ms to make them exclusive.
    
    private var oldestTimestamp: Int64? {
        if let timestamp = items.reduce(nil, combine: { timestamp, item in
            min(timestamp ?? Int64.max, (item as! PaginatableItem).createdAt.paginationTimestamp)
        }) {
            return timestamp - 1
        }
        
        return nil
    }
    
    private var newestTimestamp: Int64? {
        if let timestamp = items.reduce(nil, combine: { timestamp, item in
            max(timestamp ?? 0, (item as! PaginatableItem).createdAt.paginationTimestamp)
        }) {
            return timestamp + 1
        }
        
        return nil
    }
}

private extension NSDate {
    var paginationTimestamp: Int64 {
        // Must use Int64 to avoid overflow issues with 32 bit ints.
        return Int64(timeIntervalSince1970 * 1000.0)
    }
}
