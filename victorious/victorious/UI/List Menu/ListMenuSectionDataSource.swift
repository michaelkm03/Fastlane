//
//  ListMenuSectionDataSource.swift
//  victorious
//
//  Created by Tian Lan on 4/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

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
    
    /// The visible items fetched from backend and should be displayed
    var visibleItems: [SectionItem] { get }
    
    /// Kick off a network request to fetch data and fill `visibleItems`
    func fetchRemoteData()
    
    /// Dequeues a cell from the data source. The return type `Cell` will be specified by conformer.
    /// Default implementation will dequeue the cell, configure the cell with `SectionItem`, and set `dependencyManager` on it
    func dequeueCell(from collectionView: UICollectionView, for indexPath: NSIndexPath) -> Cell
    
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
    
    func dequeueCell(from collectionView: UICollectionView, for indexPath: NSIndexPath) -> Cell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Cell.defaultSwiftReuseIdentifier, forIndexPath: indexPath) as! Cell
        cell.configureCell(with: visibleItems[indexPath.row])
        cell.dependencyManager = dependencyManager
        
        return cell
    }
    
    func setupDataSource(with delegate: ListMenuSectionDataSourceDelegate) {
        self.delegate = delegate
        fetchRemoteData()
    }
}
