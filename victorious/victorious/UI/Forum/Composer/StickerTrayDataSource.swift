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
        static let emptyCellReuseIdentifier = UICollectionViewCell.defaultReuseIdentifier
        static let stickerCellReuseIdentifier = MediaSearchPreviewCell.defaultReuseIdentifier
    }
    
    let dependencyManager: VDependencyManager
    var dataSourceDelegate: TrayDataSourceDelegate?
    private var stickers: [GIFSearchResultObject] = []
    private var trayState: TrayState = .Empty {
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
        //TODO: Handle failure with proper cells
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: Constants.emptyCellReuseIdentifier)
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
                        completion?( error )
            }
        )
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch trayState {
        case .Empty, .FailedToLoad, .Loading:
            return 1
        case .Populated:
            return stickers.count
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch trayState {
        case .Populated:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.stickerCellReuseIdentifier, forIndexPath: indexPath) as! MediaSearchPreviewCell
            cell.activityIndicator.stopAnimating()
            if let sticker = asset(atIndex: indexPath.row) {
                cell.assetUrl = sticker.sourceMediaURL
            }
            return cell
        default:
            return collectionView.dequeueReusableCellWithReuseIdentifier(Constants.stickerCellReuseIdentifier, forIndexPath: indexPath)
        }
    }
}

private extension VDependencyManager {
    var contentFetchEndpoint: String? {
        return stringForKey("default.content.endpoint")
    }
}
