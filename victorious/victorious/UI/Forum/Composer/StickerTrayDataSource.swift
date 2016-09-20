//
//  StickerTrayDataSource.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class StickerTrayDataSource: PaginatedDataSource, TrayDataSource {
    private struct Constants {
        static let loadingCellReuseIdentifier = TrayLoadingCollectionViewCell.defaultReuseIdentifier
        static let retryCellReuseIdentifier = TrayRetryLoadCollectionViewCell.defaultReuseIdentifier
        static let defaultCellReuseIdentifier = UICollectionViewCell.defaultReuseIdentifier
        static let stickerCellReuseIdentifier = MediaSearchPreviewCell.defaultReuseIdentifier
    }
    
    let dependencyManager: VDependencyManager
    var dataSourceDelegate: TrayDataSourceDelegate?
    private var stickers: [GIFSearchResultObject] = []
    private(set) var trayState: TrayState = .Empty {
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
    
    func registerCells(withCollectionView collectionView: UICollectionView) {
        collectionView.registerClass(TrayLoadingCollectionViewCell.self, forCellWithReuseIdentifier: Constants.loadingCellReuseIdentifier)
        collectionView.registerClass(TrayRetryLoadCollectionViewCell.self, forCellWithReuseIdentifier: Constants.retryCellReuseIdentifier)
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: Constants.defaultCellReuseIdentifier)
        collectionView.registerNib(MediaSearchPreviewCell.associatedNib, forCellWithReuseIdentifier: Constants.stickerCellReuseIdentifier)
    }
    
    func fetchStickers(completion: (NSError? -> ())? = nil) {
        trayState = .Loading
        let contentFetchEndpoint = dependencyManager.contentFetchEndpoint ?? ""
        let searchOptions = GIFSearchOptions.Trending(url: contentFetchEndpoint)
        self.loadPage( .First,
                       createOperation: {
                        return GIFSearchOperation(searchOptions: searchOptions)
            },
                       completion:{ [weak self] (results, error, cancelled) in
                        guard let strongSelf = self else {
                            return
                        }
                        
                        let stickers = results as? [GIFSearchResultObject]
                        strongSelf.stickers = stickers ?? []
                        guard let results = results else {
                            strongSelf.trayState = .FailedToLoad
                            return
                        }
                        strongSelf.trayState = results.count > 0 ? .Populated : .Empty
                        completion?(error)
            }
        )
    }
    
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
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        switch trayState {
            case .Populated:
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.stickerCellReuseIdentifier, forIndexPath: indexPath) as! MediaSearchPreviewCell
                cell.activityIndicator.stopAnimating()
                if let sticker = asset(atIndex: indexPath.row) {
                    cell.assetUrl = sticker.sourceMediaURL
                }
                return cell
            case .FailedToLoad:
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.retryCellReuseIdentifier, forIndexPath: indexPath)
            case .Loading:
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.loadingCellReuseIdentifier, forIndexPath: indexPath)
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
