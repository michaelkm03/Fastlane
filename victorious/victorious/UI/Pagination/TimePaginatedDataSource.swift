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
    
    /// Loads a new page of content.
    ///
    /// The `items` array will be updated automatically before `completion` is called.
    ///
    /// This method does nothing if a page is already being loaded.
    ///
    func loadPage(pageType: VPageType, completion: (newItems: [Item], error: NSError?) -> Void) {
        guard !isLoadingPage else {
            return
        }
        
        guard let url = processedURL(for: pageType) else {
            assertionFailure("Failed to construct a valid URL when loading a page in TimePaginatedDataSource.")
            return
        }
        
        isLoadingPage = true
        
        createOperation(url: url).queue { [weak self] newItems, error in
            switch pageType {
                case .First:    self?.items = newItems
                case .Previous: self?.items = newItems + (self?.items ?? [])
                case .Next:     self?.items.appendContentsOf(newItems)
            }
            
            self?.isLoadingPage = false
            
            completion(newItems: newItems, error: error)
        }
    }
    
    private func processedURL(for pageType: VPageType) -> NSURL? {
        let (fromTime, toTime) = paginationTimestamps(for: pageType)
        
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
    
    private func paginationTimestamps(for pageType: VPageType) -> (fromTime: Int, toTime: Int) {
        let now = NSDate().paginationTimestamp
        
        switch pageType {
            case .Next, .First:
                return (fromTime: now, toTime: oldestTimestamp ?? 0)
            case .Previous:
                return (fromTime: newestTimestamp ?? now, toTime: 0)
        }
    }
    
    private var oldestTimestamp: Int? {
        guard let firstItem = items.first else {
            return nil
        }
        
        return (firstItem as! PaginatableItem).createdAt.paginationTimestamp
    }
    
    private var newestTimestamp: Int? {
        guard let lastItem = items.last else {
            return nil
        }
        
        return (lastItem as! PaginatableItem).createdAt.paginationTimestamp
    }
}

private extension NSDate {
    var paginationTimestamp: Int {
        return Int(timeIntervalSince1970 * 1000.0)
    }
}
