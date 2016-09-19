//
//  TrayDataSource.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol TrayDataSource: UICollectionViewDataSource {
    associatedtype AssetType
    weak var dataSourceDelegate: TrayDataSourceDelegate? { get set }
    func asset(atIndex index: Int) -> AssetType?
}

protocol TrayDataSourceDelegate: class {
    var collectionView: UICollectionView! { get }
    func trayDataSource<DataSource: TrayDataSource>(trayDataSource: DataSource, changedToState state: TrayState)
}

extension TrayDataSourceDelegate {
    func trayDataSource<DataSource: TrayDataSource>(trayDataSource: DataSource, changedToState state: TrayState) {
        collectionView.reloadData()
    }
}

enum TrayState {
    case Empty
    case Loading
    case FailedToLoad
    case Populated
}