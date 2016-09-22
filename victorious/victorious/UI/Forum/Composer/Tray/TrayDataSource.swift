//
//  TrayDataSource.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

enum TrayState {
    case Empty
    case Loading
    case FailedToLoad
    case Populated
}

// Conformers describe an object that provide data for a tray's collection view
protocol TrayDataSource: UICollectionViewDataSource {
    associatedtype AssetType
    weak var dataSourceDelegate: TrayDataSourceDelegate? { get set }
    func asset(atIndex index: Int) -> AssetType?
}

// Conformers will receive messages about state changes in a tray data source.
protocol TrayDataSourceDelegate: class {
    var collectionView: UICollectionView! { get }
    // The default implementation of this method simply reloads the collection view after a state change.
    func trayDataSource<DataSource: TrayDataSource>(trayDataSource: DataSource, changedToState state: TrayState)
}

extension TrayDataSourceDelegate {
    func trayDataSource<DataSource: TrayDataSource>(trayDataSource: DataSource, changedToState state: TrayState) {
        collectionView.reloadData()
    }
}
