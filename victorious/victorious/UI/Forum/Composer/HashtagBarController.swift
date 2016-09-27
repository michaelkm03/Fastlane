//
//  HashtagBarController.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// Conformers receive messages when a hashtag is selected.
protocol HashtagBarControllerSelectionDelegate: class {
    func hashtagBarController(_ hashtagBarController: HashtagBarController, selectedHashtag hashtag: String)
}

/// Conformers receive messages when a hashtag is selected.
protocol HashtagBarControllerSearchDelegate: class {
    func hashtagBarController(_ hashtagBarController: HashtagBarController, populatedWithHashtags hashtags: [String])
}

/// Manages the display of and responds to delegate methods related to a collection view populated with hashtags.
class HashtagBarController: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    fileprivate static let collectionViewInset = UIEdgeInsetsMake(0, 20, 0, 20)
        
    fileprivate let cachedSizes = NSCache()
    
    fileprivate let cellDecorator: HashtagBarCellDecorator?
    
    fileprivate let collectionView: UICollectionView
    
    fileprivate var currentTrendingTags = [String]() {
        didSet {
            guard currentTrendingTags != oldValue else {
                return
            }
            searchResults = currentTrendingTags
        }
    }
    
    fileprivate var searchResults = [String]() {
        didSet {
            var hashtags = searchResults
            if let searchText = searchText , !searchText.isEmpty {
                hashtags = [searchText] + hashtags
            }
            searchDelegate?.hashtagBarController(self, populatedWithHashtags: hashtags)
            collectionView.reloadData()
        }
    }
    
    fileprivate var currentFetchOperation: AsyncOperation<[Hashtag]>? {
        didSet {
            if oldValue != currentFetchOperation {
                oldValue?.cancel()
            }
        }
    }
    
    fileprivate var hasValidSearchText: Bool {
        return !(searchText?.isEmpty ?? true)
    }
    
    var searchText: String? {
        didSet {
            guard let searchText = searchText else {
                searchResults = []
                return
            }
            
            if !searchText.isEmpty {
                searchForText(searchText)
            } else {
                getTrendingHashtags()
            }
        }
    }
    
    fileprivate let searchAPIPath: APIPath?
    
    fileprivate let trendingAPIPath: APIPath?
    
    weak var selectionDelegate: HashtagBarControllerSelectionDelegate?
    
    weak var searchDelegate: HashtagBarControllerSearchDelegate?
    
    init(dependencyManager: VDependencyManager, collectionView: UICollectionView) {
        cellDecorator = HashtagBarCellDecorator(dependencyManager: dependencyManager)
        searchAPIPath = dependencyManager.hashtagSearchAPIPath
        trendingAPIPath = dependencyManager.trendingHashtagsAPIPath
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
    
    fileprivate func preferredCellSize(_ searchText: String = "#") -> CGSize {
        guard let cellDecorator = cellDecorator else {
            return .zero
        }
        
        if let cachedValue = cachedSizes.object(forKey: searchText) as? NSValue {
            return cachedValue.CGSizeValue
        }
        
        let boundingRect = (searchText as NSString).boundingRectWithSize(CGSize(width: CGFloat.max, height: UIScreen.main.bounds.height), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName : cellDecorator.font], context: nil)
        let size = CGSize(width: ceil(boundingRect.width) + 10, height: ceil(boundingRect.height) + 10)
        cachedSizes.setObject(NSValue(CGSize: size), forKey: searchText)
        return size
    }
    
    // MARK: - Hashtag updating
    
    fileprivate func searchForText(_ text: String) {
        guard
            let searchAPIPath = searchAPIPath,
            let request = HashtagSearchRequest(apiPath: searchAPIPath, searchTerm: text)
        else {
            return
        }
        
        currentFetchOperation = RequestOperation(request: request)
        
        currentFetchOperation?.queue { [weak self] result in
            switch result {
                case .success(let hashtags):
                    self?.searchResults = hashtags.map { $0.tag }.filter { tag in
                        let matchRange = (tag as NSString).rangeOfString(text)
                        guard matchRange.location == 0 else {
                            return false
                        }
                        return tag != text
                    }
                
                case .failure(_), .cancelled:
                    break
            }
        }
    }
    
    fileprivate func getTrendingHashtags() {
        guard
            let trendingAPIPath = trendingAPIPath,
            let request = TrendingHashtagsRequest(apiPath: trendingAPIPath)
        else {
            return
        }
        
        searchResults = currentTrendingTags
        
        currentFetchOperation = RequestOperation(request: request)
        
        currentFetchOperation?.queue { [weak self] result in
            switch result {
                case .success(let hashtags): self?.currentTrendingTags = hashtags.map { $0.tag }
                case .failure(_), .cancelled: break
            }
        }
    }

    // MARK: - Helpers
    
    fileprivate func hashtagAtIndex(_ index: Int) -> String? {
        var hashtag: String?
        if hasValidSearchText, let searchText = self.searchText {
            hashtag = index == 0 ? searchText : searchResults[index - 1]
        } else if index < searchResults.count {
            hashtag = searchResults[index]
        }
        return hashtag
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(HashtagBarCell.suggestedReuseIdentifier(), forIndexPath: indexPath) as! HashtagBarCell
        let tag = hashtagAtIndex((indexPath as NSIndexPath).row)
        guard let unwrappedTag = tag else {
            cell.hidden = true
            return cell
        }
        cell.hidden = false
        cellDecorator?.decorateCell(cell)
        HashtagBarCellPopulator.populateCell(cell, withTag: unwrappedTag)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let resultsCount = searchResults.count
        return hasValidSearchText ? resultsCount + 1 : resultsCount
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sizingString = hashtagAtIndex((indexPath as NSIndexPath).row) ?? "#"
        return preferredCellSize(sizingString)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let text = hashtagAtIndex((indexPath as NSIndexPath).row)
        guard let selectedText = text else {
            assertionFailure("Selected nil text during hashtag search")
            return
        }
        selectionDelegate?.hashtagBarController(self, selectedHashtag: selectedText)
    }
}

private extension VDependencyManager {
    var hashtagSearchAPIPath: APIPath? {
        return networkResources?.apiPathForKey("hashtag.search.URL")
    }
    
    var trendingHashtagsAPIPath: APIPath? {
        return networkResources?.apiPathForKey("trendingHashtagsURL")
    }
}
