//
//  HashtagBarController.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// Manages the display of and responds to delegate methods related to a collection view populated with hashtags.
class HashtagBarController: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private static let collectionViewInset = UIEdgeInsetsMake(0, 20, 0, 20)
        
    private var cachedSizes = NSCache()
    
    private let cellDecorator: HashtagBarCellDecorator?
    
    private let collectionView: UICollectionView
    
    private var currentTrendingTags: [String]? {
        didSet {
            guard let trendingTags = currentTrendingTags else {
                if !searchResults.isEmpty {
                    searchResults = [String]()
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
    
    private var searchResults = [String]() {
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
    
    private var hasValidSearchText: Bool {
        return searchText?.characters.count >= 1
    }
    
    var searchText: String? {
        didSet {
            guard let searchText = searchText else {
                searchResults = []
                return
            }
            
            if searchText.characters.count > 0 {
                searchForText(searchText)
            } else {
                getTrendingHashtags()
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
        collectionView.delegate = self
        collectionView.registerNib(HashtagBarCell.nibForCell(), forCellWithReuseIdentifier: HashtagBarCell.suggestedReuseIdentifier())
        collectionView.contentInset = HashtagBarController.collectionViewInset
    }
    
    deinit {
        currentFetchOperation?.cancel()
    }
    
    // MARK: - Height determination
    
    var preferredHeight: CGFloat {
        return ceil(preferredCellSize().height * 1.5)
    }
    
    var preferredCollectionViewHeight: CGFloat {
        return preferredCellSize().height
    }
    
    private func preferredCellSize(searchText: String = "#") -> CGSize {
        
        guard let cellDecorator = cellDecorator else {
            return .zero
        }
        
        if let cachedValue = cachedSizes.objectForKey(searchText) as? NSValue {
            return cachedValue.CGSizeValue()
        }
        
        let boundingRect = (searchText as NSString).boundingRectWithSize(CGSizeMake(CGFloat.max, UIScreen.mainScreen().bounds.height), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName : cellDecorator.font], context: nil)
        let size = CGSize(width: ceil(boundingRect.width) + 10, height: ceil(boundingRect.height) + 10)
        cachedSizes.setObject(NSValue(CGSize: size), forKey: searchText)
        return size
    }
    
    // MARK: - Hashtag updating
    
    private func searchForText(text: String) {
        currentFetchOperation = HashtagSearchOperation(searchTerm: text)
        currentFetchOperation?.queue() { [weak self] results, error, success in
            guard let results = results as? [HashtagSearchResultObject] else {
                return
            }
            let tags = results.map({ return $0.tag })
            self?.searchResults = tags.filter() { tag -> Bool in
                let matchRange = (tag as NSString).rangeOfString(text)
                guard matchRange.location == 0 else {
                    return false
                }
                return tag != text
            }
        }
    }
    
    private func getTrendingHashtags() {
        if let oldTrending = self.currentTrendingTags {
            searchResults = oldTrending
        }
        
        currentFetchOperation = TrendingHashtagOperation()
        currentFetchOperation?.queue() { [weak self] results, error, success in
            guard let results = results as? [HashtagSearchResultObject] else {
                return
            }
            let tags = results.map({ return $0.tag })
            self?.currentTrendingTags = tags
        }
    }

    
    // MARK: - Helpers
    
    private func hashtagAtIndex(index: Int) -> String? {
        
        var hashtag: String?
        if hasValidSearchText, let searchText = self.searchText {
            hashtag = index == 0 ? searchText : searchResults[index - 1]
        } else if index < searchResults.count {
            hashtag = searchResults[index]
        }
        return hashtag
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(HashtagBarCell.suggestedReuseIdentifier(), forIndexPath: indexPath) as! HashtagBarCell
        let tag = hashtagAtIndex(indexPath.row)
        
        guard let unwrappedTag = tag else {
            cell.hidden = true
            return cell
        }

        cell.hidden = false
        
        cellDecorator?.decorateCell(cell)
        HashtagBarCellPopulator.populateCell(cell, withTag: unwrappedTag)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let resultsCount = searchResults.count
        return hasValidSearchText ? resultsCount + 1 : resultsCount
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let sizingString = hashtagAtIndex(indexPath.row) ?? "#"
        return preferredCellSize(sizingString)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let text = hashtagAtIndex(indexPath.row)
        guard let selectedText = text else {
            assertionFailure("Selected nil text during hashtag search")
            return
        }
        
        delegate?.hashtagBarController(self, selectedHashtag: selectedText)
    }
}
