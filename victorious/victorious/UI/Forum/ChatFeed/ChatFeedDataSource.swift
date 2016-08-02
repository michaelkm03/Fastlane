//
//  ChatFeedDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 2/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

protocol ChatFeedDataSourceDelegate: class {
    func chatFeedDataSource(dataSource: ChatFeedDataSource, didLoadItems newItems: [ChatFeedContent], loadingType: PaginatedLoadingType)
    func chatFeedDataSource(dataSource: ChatFeedDataSource, didStashItems stashedItems: [ChatFeedContent])
    func chatFeedDataSource(dataSource: ChatFeedDataSource, didUnstashItems unstashedItems: [ChatFeedContent])
    func pendingItems(for chatFeedDataSource: ChatFeedDataSource) -> [ChatFeedContent]
    var chatFeedItemWidth: CGFloat { get }
}

class ChatFeedDataSource: NSObject, ForumEventSender, ForumEventReceiver, ChatInterfaceDataSource {
    
    // MARK: Initializing
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        super.init()
    }
    
    // MARK: - Dependency manager
    
    let dependencyManager: VDependencyManager
    
    // MARK: - Managing content
    
    private(set) var visibleItems = [ChatFeedContent]()
    private(set) var stashedItems = [ChatFeedContent]()
    
    var pendingItems: [ChatFeedContent] {
        if shouldShowPendingItems {
            return delegate?.pendingItems(for: self) ?? []
        }
        else {
            return []
        }
    }
    
    var stashingEnabled = false
    var shouldShowPendingItems = true
    
    func unstash() {
        guard stashedItems.count > 0 else {
            return
        }
        
        let previouslyStashedItems = stashedItems
        
        visibleItems.appendContentsOf(stashedItems)
        stashedItems.removeAll()
        
        delegate?.chatFeedDataSource(self, didUnstashItems: previouslyStashedItems)
    }
    
    // MARK: - ForumEventReceiver
    
    func receive(event: ForumEvent) {
        switch event {
            case .handleContent(let newItems, let loadingType):
                handleItems(newItems, withLoadingType: loadingType)
            
            case .filterContent(let path):
                let isFilteredFeed = path != nil
                shouldShowPendingItems = !isFilteredFeed
                clearItems()
            
            default:
                break
        }
    }
    
    // MARK: - Internal helpers
    
    private func handleItems(newItems: [ContentModel], withLoadingType loadingType: PaginatedLoadingType) {
        switch loadingType {
            case .newer:
                let newItems = createNewItemsArray(newItems)
                
                if stashingEnabled {
                    stashedItems.appendContentsOf(newItems)
                    delegate?.chatFeedDataSource(self, didStashItems: newItems)
                }
                else {
                    visibleItems.appendContentsOf(newItems)
                    delegate?.chatFeedDataSource(self, didLoadItems: newItems, loadingType: .newer)
                }
                
            case .older:
                let newItems = createNewItemsArray(newItems)
                visibleItems = newItems + visibleItems
                delegate?.chatFeedDataSource(self, didLoadItems: newItems, loadingType: .older)
                
            case .refresh:
                let newItems = createNewItemsArray(newItems)
                visibleItems = newItems
                stashedItems = []
                delegate?.chatFeedDataSource(self, didLoadItems: newItems, loadingType: .refresh)
        }
    }
    private func createNewItemsArray(contents: [ContentModel]) -> [ChatFeedContent] {
        guard let width = delegate?.chatFeedItemWidth else {
            return []
        }
        
        return contents.flatMap(){ content in
            ChatFeedContent(content: content, width: width, dependencyManager: dependencyManager)
        }
    }
    
    private func clearItems() {
        visibleItems = []
        stashedItems = []
        delegate?.chatFeedDataSource(self, didLoadItems: [], loadingType: .refresh)
    }
    
    // MARK: - ForumEventSender
    
    weak var nextSender: ForumEventSender?
    
    // MARK: - ChatFeedNetworkDataSourceType
    
    weak var delegate: ChatFeedDataSourceDelegate?
    
    // MARK: - UICollectionViewDataSource
    
    let sizingCell = ChatFeedMessageCell(frame: CGRectZero)
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems(for: collectionView, in: section)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return cellForItem(for: collectionView, at: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return desiredCellSize(for: collectionView, at: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: VFooterActivityIndicatorView.reuseIdentifier(), forIndexPath: indexPath) as! VFooterActivityIndicatorView
        }
        
        assertionFailure("Unsupported supplementary view kind requested in ChatFeedDataSource.")
        return UICollectionReusableView()
    }
}
