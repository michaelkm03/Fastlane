//
//  ListMenuSectionDataSource.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK

/// Possible states for List Menu Data Source based on the results fetched
enum ListMenuDataSourceState {
    case loading
    case failed(error: Error?)
    case items
    case noContent
}

/// A generic data source for a section in ListMenu. You'll need to specialize it with two types:
/// - Item: Item that it manages
/// - Operation: Any operation that conforms to Queueable
class ListMenuSectionDataSource<Item, Operation: Queueable> {

    // MARK: - Initialization
    typealias CellConfigurationCallback = (ListMenuSectionCell, Item) -> Void
    typealias CreateOperationCallback = () -> Operation?
    typealias ProcessOutputCallback = (Operation.Output) -> [Item]
    /// Used for configing the cell after it's creation
    let cellConfiguration: CellConfigurationCallback
    /// Defines how an operation should be created
    let createOperation: CreateOperationCallback
    /// Defines how operation output should be processed into items
    let processOutput: ProcessOutputCallback
    /// The section that this data source represents
    let section: ListMenuSection
    /// The delegate to be notified when data get updated
    weak var delegate: ListMenuSectionDataSourceDelegate?
    /// The current state of the data source based on its results
    var state: ListMenuDataSourceState = .loading

    /// Initializer
    /// - parameter dependencyManager: A dependencyManager for a section
    /// - parameter cellConfiguration: This callback will be called to configure a cell while dequeueing it.
    /// - parameter createOperation: Specify how your operation need to be created
    /// - parameter processOutput: This block defines how operation output is parsed to a list of items
    /// - parameter section: section which this data source represents
    init(dependencyManager: VDependencyManager, cellConfiguration: @escaping CellConfigurationCallback, createOperation: @escaping CreateOperationCallback, processOutput: @escaping ProcessOutputCallback, section: ListMenuSection) {
        self.dependencyManager = dependencyManager
        self.cellConfiguration = cellConfiguration
        self.createOperation = createOperation
        self.processOutput = processOutput
        self.section = section
    }

    // MARK: - Dependency manager

    /// The data source's dependency manager
    let dependencyManager: VDependencyManager

    /// APIPath for a stream behind the item
    var streamAPIPath: APIPath {
        return dependencyManager.apiPath(forKey: "streamURL") ?? APIPath(templatePath: "")
    }

    /// Tracking APIPaths
    var streamTrackingAPIPaths: [APIPath] {
        return dependencyManager.trackingAPIPaths(forEventKey: "view") ?? []
    }

    // MARK: - Cell Lifecycle

    /// Dequeue a cell that represents an item with data
    func dequeueItemCell(from collectionView: UICollectionView, at indexPath: IndexPath) -> ListMenuSectionCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListMenuSectionCell.defaultReuseIdentifier, for: indexPath) as! ListMenuSectionCell
        cellConfiguration(cell, visibleItems[indexPath.row])
        cell.dependencyManager = dependencyManager
        return cell
    }

    /// MARK: - Data Fetch

    /// Performs all work necessary after initialization to get the data source ready for use
    func setupDataSource(with delegate: ListMenuSectionDataSourceDelegate) {
        self.delegate = delegate
        fetchData()
    }

    /// Kick off an operation to fetch data and fill `visibleItems`
    func fetchData(success: (([Item]) -> Void)? = nil, failure: ((Error) -> Void)? = nil, cancelled: ((Void) -> Void)? = nil) {
        let operation = createOperation()
        operation?.queue() { [weak self] result in
            guard let strongSelf = self else {
                return
            }

            guard let output = result.output else {
                return
            }

            let items = strongSelf.processOutput(output)

            switch result {
                case .success:
                    strongSelf.visibleItems = items
                    strongSelf.delegate?.didUpdateVisibleItems(forSection: strongSelf.section)
                    success?(items)
                case .failure(let error):
                    strongSelf.state = .failed(error: error)
                    strongSelf.delegate?.didUpdateVisibleItems(forSection: strongSelf.section)
                    failure?(error)
                case .cancelled:
                    strongSelf.delegate?.didUpdateVisibleItems(forSection: strongSelf.section)
                    cancelled?()
            }
        }
    }

    /// MARK: - Items

    /// The visible items fetched from backend and should be displayed
    var visibleItems: [Item] = [Item]() {
        didSet {
            state = visibleItems.isEmpty ? .noContent : .items
            delegate?.didUpdateVisibleItems(forSection: .hashtags)
        }
    }

    /// The number of items to show for this data source, based on its `state` and `visibleItems`
    var numberOfItems: Int {
        switch state {
        case .loading, .failed, .noContent:
            return 1
        case .items:
            return visibleItems.count
        }
    }
}
