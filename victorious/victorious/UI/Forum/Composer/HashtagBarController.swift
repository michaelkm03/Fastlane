//
//  HashtagBarController.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class HashtagBarController: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private let cellDecorator: HashtagBarCellDecorator?
    
    private let collectionView: UICollectionView
    
    private var currentTrendingTags: [VHashtag]? {
        didSet {
            guard let trendingTags = currentTrendingTags else {
                if !searchResults.isEmpty {
                    searchResults = [VHashtag]()
                }
                return
            }
            
            guard let oldTrendingTags = oldValue else {
                searchResults = trendingTags
                return
            }
            
            if trendingTags != oldTrendingTags {
                searchResults = trendingTags
            }
        }
    }
    
    private var searchResults = [VHashtag]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var currentFetchOperation: RemoteFetcherOperation? {
        didSet {
            if let oldOperation = oldValue {
                oldOperation.cancel()
            }
        }
    }
    
    let dependencyManager: VDependencyManager
    
    var searchText: String? {
        didSet {
            if let searchText = searchText {
                currentFetchOperation = HashtagSearchOperation(searchTerm: searchText)
                currentFetchOperation?.queue() { [weak self] results, error, success in
                    guard let results = results as? [VHashtag] where success else {
                        return
                    }
                    self?.searchResults = results.filter() { hashtag -> Bool in
                        return hashtag.tag != searchText
                    }
                }
            } else {
                //Nil search, get trending tags
                currentFetchOperation = TrendingHashtagOperation()
                currentFetchOperation?.queue() { [weak self] results, error, success in
                    guard let results = results as? [VHashtag] where success else {
                        return
                    }
                    self?.currentTrendingTags = results
                }
            }
        }
    }
    
    weak var delegate: HashtagBarControllerDelegate?
    
    init(dependencyManager: VDependencyManager, collectionView: UICollectionView) {
        self.dependencyManager = dependencyManager
        cellDecorator = HashtagBarCellDecorator(dependencyManager: dependencyManager)
        self.collectionView = collectionView
        super.init()
        collectionView.dataSource = self
        collectionView.registerNib(HashtagBarCell.nibForCell(), forCellWithReuseIdentifier: HashtagBarCell.suggestedReuseIdentifier())
    }
    
    deinit {
        currentFetchOperation?.cancel()
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(HashtagBarCell.suggestedReuseIdentifier(), forIndexPath: indexPath) as! HashtagBarCell
        var index = indexPath.row
        var tag: String?
        
        if let searchText = searchText {
            if index == 0 {
                tag = searchText
            } else {
                index -= 1
            }
        }
        
        if tag == nil {
            let currentSearchResults = searchResults
            guard index < currentSearchResults.count else {
                cell.hidden = true
                return cell
            }
            cell.hidden = false
            tag = currentSearchResults[index].tag
        }
        
        guard let unwrappedTag = tag else {
            fatalError("Found nil tag when trying to populate hashtag cell")
        }
        
        cellDecorator?.decorateCell(cell, selected: false)
        HashtagBarCellPopulator.populateCell(cell, withTag: unwrappedTag)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let resultsCount = searchResults.count
        return searchText != nil ? resultsCount + 1 : resultsCount
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.hashtagBarController(self, selectedHashtag: searchResults[indexPath.row])
    }
}
