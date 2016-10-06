//
//  ListMenuSectionDataSource.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

/// Possible states for List Menu Data Source based on the results fetched
enum ListMenuDataSourceState {
    case loading
    case failed(error: ErrorType?)
    case items
    case noContent
}

class ListMenuSectionDataSource<Item, Operation: Queueable> {

    // MARK: - Initialization
    typealias CellConfigurationCallback = (cell: ListMenuSectionCell, item: Item) -> Void
    typealias CreateOperationCallback = () -> Operation?
    typealias ProcessOutputCallback = (output: Operation.Output) -> [Item]
    let cellConfiguration: CellConfigurationCallback
    let createOperation: CreateOperationCallback
    let processOutput: ProcessOutputCallback
    let section: ListMenuSection
    weak var delegate: ListMenuSectionDataSourceDelegate?
    var state: ListMenuDataSourceState = .loading
    var requestExecutor: RequestExecutorType = MainRequestExecutor()

    init(dependencyManager: VDependencyManager, cellConfiguration: CellConfigurationCallback, createOperation: CreateOperationCallback, processOutput: ProcessOutputCallback, section: ListMenuSection) {
        self.dependencyManager = dependencyManager
        self.cellConfiguration = cellConfiguration
        self.createOperation = createOperation
        self.processOutput = processOutput
        self.section = section
    }

    // MARK - Dependency manager

    let dependencyManager: VDependencyManager

    var streamAPIPath: APIPath {
        return dependencyManager.apiPathForKey("streamURL") ?? APIPath(templatePath: "")
    }

    var streamTrackingAPIPaths: [APIPath] {
        return dependencyManager.trackingAPIPaths(forEventKey: "view") ?? []
    }

    // MARK: - Cell Lifecycle

    func dequeueItemCell(from collectionView: UICollectionView, at indexPath: NSIndexPath) -> ListMenuSectionCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ListMenuSectionCell.defaultReuseIdentifier, forIndexPath: indexPath) as! ListMenuSectionCell
        cellConfiguration(cell: cell, item: visibleItems[indexPath.row])
        cell.dependencyManager = dependencyManager
        cell.dependencyManager = dependencyManager
        return cell
    }

    func setupDataSource(with delegate: ListMenuSectionDataSourceDelegate) {
        self.delegate = delegate
        fetchData()
    }

    func fetchData(success success: ((with: [Item]) -> Void)? = nil, failure: ((with: ErrorType) -> Void)? = nil, cancelled: (Void -> Void)? = nil) {
        let operation = createOperation()
        operation?.queue() { [weak self] result in
            guard let strongSelf = self else {
                return
            }

            guard let output = result.output else {
                return
            }

            let items = strongSelf.processOutput(output: output)

            switch result {
                case .success:
                    strongSelf.visibleItems = items
                    strongSelf.delegate?.didUpdateVisibleItems(forSection: strongSelf.section)
                    success?(with: items)
                case .failure(let error):
                    strongSelf.state = .failed(error: error)
                    strongSelf.delegate?.didUpdateVisibleItems(forSection: strongSelf.section)
                    failure?(with: error)
                case .cancelled:
                    strongSelf.delegate?.didUpdateVisibleItems(forSection: strongSelf.section)
                    cancelled?()
            }
        }
    }

    var visibleItems: [Item] = [Item]() {
        didSet {
            state = visibleItems.isEmpty ? .noContent : .items
            delegate?.didUpdateVisibleItems(forSection: .hashtags)
        }
    }

    var numberOfItems: Int {
        switch state {
        case .loading, .failed, .noContent:
            return 1
        case .items:
            return visibleItems.count
        }
    }
}
