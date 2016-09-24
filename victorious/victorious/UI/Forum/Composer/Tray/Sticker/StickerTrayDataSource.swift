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
    private struct Constants {
        static let loadingCellReuseIdentifier = TrayLoadingCollectionViewCell.defaultReuseIdentifier
        static let retryCellReuseIdentifier = TrayRetryLoadCollectionViewCell.defaultReuseIdentifier
        static let defaultCellReuseIdentifier = UICollectionViewCell.defaultReuseIdentifier
        static let stickerCellReuseIdentifier = MediaSearchPreviewCell.defaultReuseIdentifier
    }
    
    let dependencyManager: VDependencyManager
    var dataSourceDelegate: TrayDataSourceDelegate?
    private var stickers: [StickerSearchResultObject] = []
    private(set) var trayState: TrayState = .Empty {
        didSet {
            if oldValue != trayState {
                dataSourceDelegate?.trayDataSource(self, changedToState: trayState)
            }
        }
    }
    var cellSize: CGSize = .zero
    
    func asset(atIndex index: Int) -> StickerSearchResultObject? {
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
    
    func fetchStickers(completion: (NSError? -> ())? = nil) {
        trayState = .Loading
        let contentFetchEndpoint = dependencyManager.contentFetchEndpoint ?? ""
        let searchOptions = AssetSearchOptions.Trending(url: contentFetchEndpoint)
        let createOperation = {
            return StickerSearchOperation(searchOptions: searchOptions)
        }
        let pageLoadCompletion = { [weak self] (results: [AnyObject]?, error: NSError?, cancelled: Bool) in
            guard let strongSelf = self else {
                return
            }

            let stickers = results as? [StickerSearchResultObject] ?? strongSelf.stickers
            strongSelf.stickers = stickers
            guard stickers.count > 0 else {
                strongSelf.trayState = .FailedToLoad
                return
            }
            strongSelf.trayState = .Populated
            completion?(error)
        }
        self.loadPage(.First, createOperation: createOperation, completion: pageLoadCompletion)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch trayState {
            case .Empty:
                return 0
            case .FailedToLoad, .Loading:
                return 1
            case .Populated:
                return stickers.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        switch trayState {
            case .Populated:
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.stickerCellReuseIdentifier, forIndexPath: indexPath) as! MediaSearchPreviewCell
                cell.activityIndicator.stopAnimating()
                if let sticker = asset(atIndex: indexPath.row) {
                    cell.previewAssetUrl = sticker.thumbnailImageURL
                }
                return cell
            case .FailedToLoad:
                let retryCell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.retryCellReuseIdentifier, forIndexPath: indexPath) as! TrayRetryLoadCollectionViewCell
                retryCell.imageView.tintColor = .blackColor()
                cell = retryCell
            case .Loading:
                let loadingCell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.loadingCellReuseIdentifier, forIndexPath: indexPath) as! TrayLoadingCollectionViewCell
            loadingCell.activityIndicator.color = .blackColor()
            cell = loadingCell
            case .Empty:
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.defaultCellReuseIdentifier, forIndexPath: indexPath)
        }
        cell.backgroundColor = .clearColor()
        cell.contentView.backgroundColor = .clearColor()
        return cell
    }
}

private extension VDependencyManager {
    var contentFetchEndpoint: String? {
        return stringForKey("default.content.endpoint")
    }
}
