//
//  StickerTrayDataSource.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A data source that fetches stickers and provides cells that show non-animating previews of these stickers
class StickerTrayDataSource: PaginatedDataSource, TrayDataSource {
    fileprivate struct Constants {
        static let loadingCellReuseIdentifier = TrayLoadingCollectionViewCell.defaultReuseIdentifier
        static let retryCellReuseIdentifier = TrayRetryLoadCollectionViewCell.defaultReuseIdentifier
        static let defaultCellReuseIdentifier = UICollectionViewCell.defaultReuseIdentifier
        static let stickerCellReuseIdentifier = MediaSearchPreviewCell.defaultReuseIdentifier
    }
    
    let dependencyManager: VDependencyManager
    var dataSourceDelegate: TrayDataSourceDelegate?
    fileprivate var stickers: [GIFSearchResultObject] = []
    fileprivate(set) var trayState: TrayState = .empty {
        didSet {
            if oldValue != trayState {
                dataSourceDelegate?.trayDataSource(self, changedToState: trayState)
            }
        }
    }
    
    func asset(atIndex index: Int) -> GIFSearchResultObject? {
        guard stickers.count > index else {
            return nil
        }
        return stickers[index]
    }
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
    }
    
    // This method must be called on the collection view that this object will provide cells for prior to dequeueing any cells
    func registerCells(withCollectionView collectionView: UICollectionView) {
        collectionView.registerClass(TrayLoadingCollectionViewCell.self, forCellWithReuseIdentifier: Constants.loadingCellReuseIdentifier)
        collectionView.registerClass(TrayRetryLoadCollectionViewCell.self, forCellWithReuseIdentifier: Constants.retryCellReuseIdentifier)
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: Constants.defaultCellReuseIdentifier)
        collectionView.registerNib(MediaSearchPreviewCell.associatedNib, forCellWithReuseIdentifier: Constants.stickerCellReuseIdentifier)
    }
    
    func fetchStickers(_ completion: ((NSError?) -> ())? = nil) {
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
            
            let stickers = results as? [GIFSearchResultObject] ?? strongSelf.stickers
            strongSelf.stickers = stickers
            guard stickers.count > 0 else {
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
                return stickers.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        switch trayState {
            case .populated:
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.stickerCellReuseIdentifier, forIndexPath: indexPath) as! MediaSearchPreviewCell
                cell.activityIndicator.stopAnimating()
                if let sticker = asset(atIndex: indexPath.row) {
                    cell.previewAssetUrl = sticker.thumbnailImageURL
                }
                return cell
            case .failedToLoad:
                let retryCell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.retryCellReuseIdentifier, forIndexPath: indexPath) as! TrayRetryLoadCollectionViewCell
                retryCell.imageView.tintColor = .black
                cell = retryCell
            case .loading:
                let loadingCell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.loadingCellReuseIdentifier, forIndexPath: indexPath) as! TrayLoadingCollectionViewCell
            loadingCell.activityIndicator.color = .black
            cell = loadingCell
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
