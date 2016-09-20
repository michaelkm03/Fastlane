//
//  GIFTrayDataSource.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class GIFTrayDataSource: PaginatedDataSource, TrayDataSource {
    private struct Constants {
        static let emptyCellReuseIdentifier = UICollectionViewCell.defaultReuseIdentifier
        static let gifCellReuseIdentifier = MediaSearchPreviewCell.defaultReuseIdentifier
    }
    
    let dependencyManager: VDependencyManager
    var dataSourceDelegate: TrayDataSourceDelegate?
    private var gifs: [GIFSearchResultObject] = []
    private var trayState: TrayState = .Empty {
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
    
    func registerCells(withCollectionView collectionView: UICollectionView) {
        //TODO: Handle failure with proper cells
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: Constants.emptyCellReuseIdentifier)
        collectionView.registerNib(MediaSearchPreviewCell.associatedNib, forCellWithReuseIdentifier: Constants.gifCellReuseIdentifier)
    }
    
    func fetchGifs(completion: (NSError? -> ())? = nil) {
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
                        
                        let gifs = results as? [GIFSearchResultObject]
                        strongSelf.gifs = gifs ?? []
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
            return gifs.count
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch trayState {
        case .Populated:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.gifCellReuseIdentifier, forIndexPath: indexPath) as! MediaSearchPreviewCell
            if let gif = asset(atIndex: indexPath.row) {
                cell.assetUrl = gif.sourceMediaURL
                cell.previewAssetUrl = gif.thumbnailImageURL
            }
            return cell
        default:
            return collectionView.dequeueReusableCellWithReuseIdentifier(Constants.gifCellReuseIdentifier, forIndexPath: indexPath)
        }
    }
}

private extension VDependencyManager {
    var contentFetchEndpoint: String? {
        return stringForKey("default.content.endpoint")
    }
}
