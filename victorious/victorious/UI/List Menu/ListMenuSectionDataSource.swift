//
//  ListMenuSectionDataSource.swift
//  victorious
//
//  Created by Tian Lan on 4/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Possible states for List Menu Data Source based on the results fetched
enum ListMenuDataSourceState {
    case loading
    case failed(error: Error?)
    case items
    case noContent
}

typealias FetchRemoteDataCallback = () -> Void

/// Discrete data source for a section within a List Menu component.
/// Mainly in charge of fetch data from backend, and notify its delegate
protocol ListMenuSectionDataSource: class {
    associatedtype SectionItem
    associatedtype Cell

    init(dependencyManager: VDependencyManager)
    
    /// The data source's dependency manager
    var dependencyManager: VDependencyManager { get }
    
    /// The delegate to be notified when data get updated
    weak var delegate: ListMenuSectionDataSourceDelegate? { get set }
    
    /// The current state of the data source based on its results
    var state: ListMenuDataSourceState { get }
    
    /// The number of items to show for this data source, based on its `state` and `visibleItems`
    var numberOfItems: Int { get }
    
    /// The visible items fetched from backend and should be displayed
    var visibleItems: [SectionItem] { get }
    
    /// Kick off a network request to fetch data and fill `visibleItems`
    func fetchRemoteData(success: FetchRemoteDataCallback?)
    
    /// Dequeues a cell from the data source that displays a valid item in the section. The return type `Cell` will be specified by conformer.
    /// Default implementation will dequeue the cell, configure the cell with `SectionItem`, and set `dependencyManager` on it
    func dequeueItemCell(from collectionView: UICollectionView, at indexPath: IndexPath) -> Cell
    
    /// Performs initial setup work after initialization of the data source.
    /// Default implementation sets up the delegate and kicks off the initial data fetch
    func setupDataSource(with _: ListMenuSectionDataSourceDelegate)
}

/// Conformers of this protocol respond to List Menu Data Sources data update events
protocol ListMenuSectionDataSourceDelegate: class {
    
    /// Called when List Menu Network Data Sources have finished fetching data
    /// from backend, and updated its `visibleItems`
    func didUpdateVisibleItems(forSection section: ListMenuSection)
}

extension ListMenuSectionDataSource where Cell: UICollectionViewCell, Cell: ListMenuSectionCell, SectionItem == Cell.CellData {
    
    func dequeueItemCell(from collectionView: UICollectionView, at indexPath: IndexPath) -> Cell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.defaultReuseIdentifier, for: indexPath) as! Cell
        cell.configureCell(with: visibleItems[indexPath.row])
        cell.dependencyManager = dependencyManager
        
        return cell
    }
    
    func setupDataSource(with delegate: ListMenuSectionDataSourceDelegate) {
        self.delegate = delegate
        fetchRemoteData(success: nil)
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
