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
    
    init(apiPath: String, createOperation: (url: NSURL) -> Operation) {
        self.apiPath = apiPath
        self.createOperation = createOperation
    }
    
    // MARK: - Configuration
    
    let apiPath: String
    let createOperation: (url: NSURL) -> Operation
    
    // MARK: - Managing content
    
    /// The data source's list of items ordered from oldest to newest.
    private(set) var items: [Item] = []
    
    /// Keeps track of whether we're loading a page so that we don't accidentally load the same stuff a bunch of times.
    private var isLoadingPage = false
    
    /// Loads a new page of items.
    ///
    /// The `items` array will be updated automatically before `completion` is called.
    ///
    /// This method does nothing if a page is already being loaded.
    ///
    func loadItems(loadingType: PaginatedLoadingType, completion: (newItems: [Item], error: NSError?) -> Void) {
        guard !isLoadingPage else {
            return
        }
        
        guard let url = processedURL(for: loadingType) else {
            assertionFailure("Failed to construct a valid URL when loading a page in TimePaginatedDataSource.")
            return
        }
        
        isLoadingPage = true
        
        if loadingType == .refresh {
            items = []
        }
        
        createOperation(url: url).queue { [weak self] newItems, error in
            switch loadingType {
                case .refresh: self?.items = newItems
                case .newer:   self?.items = newItems + (self?.items ?? [])
                case .older:   self?.items.appendContentsOf(newItems)
            }
            
            self?.isLoadingPage = false
            
            completion(newItems: newItems, error: error)
        }
    }
    
    private func processedURL(for loadingType: PaginatedLoadingType) -> NSURL? {
        let (fromTime, toTime) = paginationTimestamps(for: loadingType)
        
        // The from-time should always come after the to-time.
        guard fromTime > toTime else {
            assertionFailure("Generated invalid pagination timestamps.")
            return nil
        }
        
        let processedPath = VSDKURLMacroReplacement().urlByReplacingMacrosFromDictionary([
            "%%FROM_TIME%%": "\(fromTime)",
            "%%TO_TIME%%": "\(toTime)"
        ], inURLString: apiPath)
        
        return NSURL(string: processedPath)
    }
    
    private func paginationTimestamps(for loadingType: PaginatedLoadingType) -> (fromTime: Int, toTime: Int) {
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
    
    private var oldestTimestamp: Int? {
        if let timestamp = items.reduce(nil, combine: { timestamp, item in
            min(timestamp ?? Int.max, (item as! PaginatableItem).createdAt.paginationTimestamp)
        }) {
            return timestamp - 1
        }
        
        return nil
    }
    
    private var newestTimestamp: Int? {
        if let timestamp = items.reduce(nil, combine: { timestamp, item in
            max(timestamp ?? 0, (item as! PaginatableItem).createdAt.paginationTimestamp)
        }) {
            return timestamp + 1
        }
        
        return nil
    }
}

private extension NSDate {
    var paginationTimestamp: Int {
        return Int(timeIntervalSince1970 * 1000.0)
    }
}
