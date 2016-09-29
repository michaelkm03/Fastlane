//
//  GIFTrayDataSource.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A data source that fetches gifs and provides cells that load and auto-play these gifs
class GIFTrayDataSource: PaginatedDataSource, TrayDataSource {
    fileprivate struct Constants {
        static let loadingCellReuseIdentifier = TrayLoadingCollectionViewCell.defaultReuseIdentifier
        static let retryCellReuseIdentifier = TrayRetryLoadCollectionViewCell.defaultReuseIdentifier
        static let defaultCellReuseIdentifier = UICollectionViewCell.defaultReuseIdentifier
        static let gifCellReuseIdentifier = MediaSearchPreviewCell.defaultReuseIdentifier
    }
    
    let dependencyManager: VDependencyManager
    var dataSourceDelegate: TrayDataSourceDelegate?
    fileprivate var gifs: [GIFSearchResultObject] = []
    fileprivate(set) var trayState: TrayState = .empty {
        didSet {
            if oldValue != trayState {
                dataSourceDelegate?.trayDataSource(self, changedToState: trayState)
            }
        }
    }
    
    func asset(atIndex index: Int) -> GIFSearchResultObject? {
        guard gifs.count > index else {
            return nil
        }
        return gifs[index]
    }
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
    }
    
    // This method must be called on the collection view that this object will provide cells for prior to dequeueing any cells
    func registerCells(withCollectionView collectionView: UICollectionView) {
        collectionView.registerClass(TrayLoadingCollectionViewCell.self, forCellWithReuseIdentifier: Constants.loadingCellReuseIdentifier)
        collectionView.registerClass(TrayRetryLoadCollectionViewCell.self, forCellWithReuseIdentifier: Constants.retryCellReuseIdentifier)
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: Constants.defaultCellReuseIdentifier)
        collectionView.registerNib(MediaSearchPreviewCell.associatedNib, forCellWithReuseIdentifier: Constants.gifCellReuseIdentifier)
    }
    
    func fetchGifs(_ completion: ((NSError?) -> ())? = nil) {
        trayState = .loading
        let contentFetchEndpoint = dependencyManager.contentFetchEndpoint ?? ""
        let searchOptions = GIFSearchOptions.Trending(url: contentFetchEndpoint)
        let createOperation = {
            return GIFSearchOperation(searchOptions: searchOptions)
        }
        let pageLoadCompletion = {
            [weak self] (results: [AnyObject]?, error: NSError?, cancelled: Bool) in
            guard let strongSelf = self else {
                return
            }
            
            let gifs = results as? [GIFSearchResultObject] ?? strongSelf.gifs
            strongSelf.gifs = gifs
            guard gifs.count > 0 else {
                strongSelf.trayState = .failedToLoad
                return
            }
            strongSelf.trayState = .populated
            completion?(error)
        }
        self.loadPage(.First, createOperation: createOperation, completion: pageLoadCompletion)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch trayState {
            case .empty:
                return 0
            case .failedToLoad, .loading:
                return 1
            case .populated:
                return gifs.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        switch trayState {
            case .populated:
                let gifCell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.gifCellReuseIdentifier, forIndexPath: indexPath) as! MediaSearchPreviewCell
                if let gif = asset(atIndex: indexPath.row) {
                    gifCell.assetUrl = gif.sourceMediaURL
                    gifCell.previewAssetUrl = gif.thumbnailImageURL
                }
                cell = gifCell
            case .failedToLoad:
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.retryCellReuseIdentifier, forIndexPath: indexPath)
            case .loading:
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.loadingCellReuseIdentifier, forIndexPath: indexPath)
            case .empty:
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.defaultCellReuseIdentifier, forIndexPath: indexPath)
        }
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        return cell
    }
}

private extension VDependencyManager {
    var contentFetchEndpoint: String? {
        return string(forKey: "default.content.endpoint")
    }
}
