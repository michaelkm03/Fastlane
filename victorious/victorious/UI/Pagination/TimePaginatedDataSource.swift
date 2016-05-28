//
//  TimePaginatedDataSource.swift
//  victorious
//
//  Created by Jarod Long on 5/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

/// An object that manages a paginated list of items retrieved from an operation using a time-based pagination system.
///
/// To use this object, you simply provide an API path with the appropriate pagination macros as well as an operation
/// that produces a list of items given a URL.
///
/// - NOTE: We should rename this to `PaginatedDataSource` once we remove the other `PaginatedDataSource`.
///
class TimePaginatedDataSource<Item, Operation: Queueable where Operation.CompletionBlockType == (newItems: [Item], error: NSError?) -> Void> {
    // MARK: - Initializing
    
    init(apiPath: String, createOperation: (url: NSURL) -> Operation) {
        self.apiPath = apiPath
        self.createOperation = createOperation
    }
    
    /// - Configuration
    
    let apiPath: String
    let createOperation: (url: NSURL) -> Operation
    
    // MARK: - Managing content
    
    /// The data source's list of items.
    private(set) var items: [Item] = []
    
    /// Loads a new page of content.
    ///
    /// The `items` array will be updated automatically before `completion` is called.
    ///
    func loadPage(pageType: VPageType, completion: (newItems: [Item], error: NSError?) -> Void) {
        let (fromTime, toTime) = paginationTimestamps(for: pageType)
        
        let processedPath = VSDKURLMacroReplacement().urlByReplacingMacrosFromDictionary([
            "%%FROM_TIME%%": "\(fromTime)",
            "%%TO_TIME%%": "\(toTime)"
        ], inURLString: apiPath)
        
        guard let url = NSURL(string: processedPath) else {
            assertionFailure("Failed to construct a valid URL when loading a page in TimePaginatedDataSource.")
            return
        }
        
        createOperation(url: url).queue { [weak self] newItems, error in
            switch pageType {
                case .First:    self?.items = newItems
                case .Previous: self?.items = newItems + (self?.items ?? [])
                case .Next:     self?.items.appendContentsOf(newItems)
            }
            
            completion(newItems: newItems, error: error)
        }
    }
    
    private func paginationTimestamps(for pageType: VPageType) -> (fromTime: Int, toTime: Int) {
        // TODO: Implement this properly.
        return (fromTime: Int(NSDate().timeIntervalSince1970 * 1000.0), toTime: 0)
    }
}
