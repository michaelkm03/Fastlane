//
//  NewListMenuSectionDataSource.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

/// Possible states for List Menu Data Source based on the results fetched
enum NewListMenuDataSourceState {
    case loading
    case failed(error: ErrorType?)
    case items
    case noContent
}

protocol NewListMenuSectionDataSourceDelegate: class {

    /// Called when List Menu Network Data Sources have finished fetching data
    /// from backend, and updated its `visibleItems`
    func didUpdateVisibleItems(forSection section: ListMenuSection)
}

class NewListMenuSectionDataSource<CellData, Request: RequestType where Request.ResultType == Array<CellData>> {

    // MARK: - Initialization
    typealias CellConfigurationCallback = (_: NewListMenuSectionCell, _: CellData)  -> Void
    typealias FetchRemoteDataCallback = (_: NewListMenuSectionDataSource) -> Void
    let cellConfigurationCallback: CellConfigurationCallback
    let fetchRequest: Request
    weak var delegate: ListMenuSectionDataSourceDelegate?
    var state: ListMenuDataSourceState = .loading
    var requestExecutor: RequestExecutorType = MainRequestExecutor()

    init(dependencyManager: VDependencyManager, cellConfigurationCallback: CellConfigurationCallback, fetchRequest: Request) {
        self.dependencyManager = dependencyManager
        self.cellConfigurationCallback = cellConfigurationCallback
        self.fetchRequest = fetchRequest
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
        cellConfigurationCallback(_: cell, _: visibleItems[indexPath.row])
        cell.dependencyManager = dependencyManager
        return cell
    }

    func setupDataSource(with delegate: ListMenuSectionDataSourceDelegate) {
        self.delegate = delegate
        let operation = RequestOperation(request: fetchRequest)
        operation.requestExecutor = requestExecutor
        operation.queue() { [weak self] result in
            switch result {
            case .success(let chatRooms):
                self?.visibleItems = chatRooms

            case .failure(let error):
                self?.state = .failed(error: error)
                self?.delegate?.didUpdateVisibleItems(forSection: .chatRooms)

            case .cancelled:
                self?.delegate?.didUpdateVisibleItems(forSection: .chatRooms)
            }
        }
    }

    var visibleItems: [CellData] = [CellData]() {
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
