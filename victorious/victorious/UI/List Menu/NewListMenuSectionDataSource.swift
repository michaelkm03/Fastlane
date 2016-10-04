//
//  NewListMenuSectionDataSource.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

class NewListMenuSectionDataSource<Item, Operation: Queueable> {

    // MARK: - Initialization
    typealias CellConfigurationCallback = (cell: NewListMenuSectionCell, item: Item) -> Void
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

    func dequeueItemCell(from collectionView: UICollectionView, at indexPath: NSIndexPath) -> NewListMenuSectionCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NewListMenuSectionCell.defaultReuseIdentifier, forIndexPath: indexPath) as! NewListMenuSectionCell
        cellConfiguration(cell: cell, item: visibleItems[indexPath.row])
        cell.dependencyManager = dependencyManager
        cell.dependencyManager = dependencyManager
        return cell
    }

    func setupDataSource(with delegate: ListMenuSectionDataSourceDelegate) {
        self.delegate = delegate
        fetchData()
    }

    func fetchData() {
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
                case .failure(let error):
                    strongSelf.state = .failed(error: error)
                    strongSelf.delegate?.didUpdateVisibleItems(forSection: strongSelf.section)
                case .cancelled:
                    strongSelf.delegate?.didUpdateVisibleItems(forSection: strongSelf.section)
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
