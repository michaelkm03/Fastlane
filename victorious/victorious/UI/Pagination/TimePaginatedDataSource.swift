//
//  TimePaginatedDataSource.swift
//  victorious
//
//  Created by Jarod Long on 5/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK

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
/// - NOTE: This should be renamed to `PaginatedDataSource` once the other `PaginatedDataSource` is removed.
///
class TimePaginatedDataSource<Item: PaginatableItem, ItemOperation: Queueable> where ItemOperation: Operation {

    // MARK: - Initializing

    init(apiPath: APIPath, ordering: PaginatedOrdering = .descending, throttleTime: TimeInterval = 1.0, startTime: Timestamp? = nil, createOperation: @escaping (_ apiPath: APIPath) -> ItemOperation?, processOutput: @escaping (_ output: ItemOperation.Output) -> [Item]) {
        self.apiPath = apiPath
        self.ordering = ordering
        self.throttleTime = throttleTime
        self.createOperation = createOperation
        self.processOutput = processOutput
        startTimes = startTime.map { ($0.predecessor, $0.successor) }
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
    let throttleTime: TimeInterval

    /// A function that converts an API path into an operation that loads a page of items.
    private let createOperation: (_ apiPath: APIPath) -> ItemOperation?

    /// A function that converts the output of the data source's operation into a list of items.
    private let processOutput: (_ output: ItemOperation.Output) -> [Item]
    
    /// The timestamps around which the first fetch of items will be based.
    let startTimes: (older: Timestamp, newer: Timestamp)?

    /// The operation that is currently loading items, if any.
    private var currentOperation: ItemOperation?

    // MARK: - Managing contents

    /// The data source's list of items ordered from oldest to newest.
    private(set) var items: [Item] = []

    /// Whether the data source is currently loading a page of items or not.
    var isLoading: Bool {
        return (currentOperation?.isCancelled == false)
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
    func loadItems(_ loadingType: PaginatedLoadingType, completion: ((_ result: OperationResult<ItemOperation.Output>) -> Void)? = nil) -> Bool {
        if loadingType == .refresh {
            currentOperation?.cancel()
            currentOperation = nil
        }

        guard shouldLoadItems(for: loadingType) else {
            return false
        }

        guard let apiPath = processedAPIPath(for: loadingType) else {
            assertionFailure("Failed to construct a valid API path when loading a page in TimePaginatedDataSource.")
            return false
        }

        lastLoadTime = NSDate()
        currentOperation = createOperation(apiPath)

        currentOperation?.queue { [weak self] result in
            defer {
                completion?(result)
            }

            guard let strongSelf = self else {
                return
            }

            strongSelf.currentOperation = nil

            guard let output = result.output else {
                return
            }

            let newItems = strongSelf.processOutput(output)

            switch loadingType {
                case .refresh:
                    strongSelf.items = newItems
                    strongSelf.olderItemsAreAvailable = true

                case .newer:
                    switch strongSelf.ordering {
                        case .descending: strongSelf.prependItems(newItems)
                        case .ascending: strongSelf.appendItems(newItems)
                    }

                case .older:
                    if newItems.count == 0 {
                        strongSelf.olderItemsAreAvailable = false
                    }

                    switch strongSelf.ordering {
                        case .descending: strongSelf.appendItems(newItems)
                        case .ascending: strongSelf.prependItems(newItems)
                    }
            }
        }

        return true
    }

    private func prependItems(_ newItems: [Item]) {
        items = newItems + items
    }

    private func appendItems(_ newItems: [Item]) {
        items.append(contentsOf: newItems)
    }

    private func processedAPIPath(for loadingType: PaginatedLoadingType) -> APIPath? {
        let (fromTime, toTime) = paginationTimestamps(for: loadingType)
        var processedAPIPath = apiPath
        processedAPIPath.macroReplacements["%%FROM_TIME%%"] = "\(fromTime)"
        processedAPIPath.macroReplacements["%%TO_TIME%%"] = "\(toTime)"
        return processedAPIPath
    }

    /// Returns the range of timestamps needed to load new content for `loadingType`.
    ///
    private func paginationTimestamps(for loadingType: PaginatedLoadingType) -> (fromTime: Timestamp, toTime: Timestamp) {
        // Backend builds pages of content based on fromTime, so that value should always be the time "index" and toTime the direction that we want to fetch in.
        let now = Timestamp()
        let (newerTime, olderTime) = startTimes ?? (now, now)
        switch loadingType {
            case .refresh: return (fromTime: newerTime, toTime: Timestamp(value: 0))
            case .newer: return (fromTime: newestTimestamp ?? newerTime, toTime: now)
            case .older: return (fromTime: oldestTimestamp ?? olderTime, toTime: Timestamp(value: 0))
        }
    }

    // NOTE: Pagination timestamps are inclusive, so to avoid retrieving multiple copies of the same item, we adjust
    // the timestamps by 1ms to make them exclusive.

    private var oldestTimestamp: Timestamp? {
        if let timestamp = items.reduce(nil, { timestamp, item in
            min(timestamp ?? Timestamp.max, item.paginationTimestamp)
        }) {
            return timestamp.predecessor
        }
        
        return nil
    }
    
    private var newestTimestamp: Timestamp? {
        if let timestamp = items.reduce(nil, { timestamp, item in
            max(timestamp ?? Timestamp(value: 0), item.paginationTimestamp)
        }) {
            return timestamp.successor
        }
        
        return nil
    }
}
