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
    func chatFeedDataSource(_ dataSource: ChatFeedDataSource, didLoadItems newItems: [ChatFeedContent], loadingType: PaginatedLoadingType)
    func chatFeedDataSource(_ dataSource: ChatFeedDataSource, didStashItems stashedItems: [ChatFeedContent])
    func chatFeedDataSource(_ dataSource: ChatFeedDataSource, didUnstashItems unstashedItems: [ChatFeedContent])
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
    
    // MARK: - Configuration
    
    /// When enabled, new items will be added to `stashedItems` rather than `unstashedItems`.
    var stashingEnabled = false
    
    /// Whether or not the pending items from the delegate should be displayed.
    fileprivate var shouldShowPendingItems = true
    
    /// Whether or not reply buttons in chat cells should be displayed.
    fileprivate(set) var shouldShowReplyButtons = true
    
    // MARK: - Managing content
    
    fileprivate(set) var unstashedItems = [ChatFeedContent]()
    fileprivate(set) var stashedItems = [ChatFeedContent]()
    
    var pendingItems: [ChatFeedContent] {
        if shouldShowPendingItems {
            return delegate?.pendingItems(for: self) ?? []
        }
        else {
            return []
        }
    }
    
    func removeUnstashedItem(at index: Int) {
        unstashedItems.remove(at: index)
    }
    
    func unstash() {
        guard stashedItems.count > 0 else {
            return
        }
        
        let previouslyStashedItems = stashedItems
        
        unstashedItems.append(contentsOf: stashedItems)
        stashedItems.removeAll()
        
        delegate?.chatFeedDataSource(self, didUnstashItems: previouslyStashedItems)
    }
    
    // MARK: - ForumEventReceiver
    
    func receive(_ event: ForumEvent) {
        switch event {
            case .handleContent(let newItems, let loadingType):
                handleItems(newItems, withLoadingType: loadingType)
            
            case .filterContent(let path):
                let isFilteredFeed = path != nil
                shouldShowPendingItems = !isFilteredFeed
                shouldShowReplyButtons = !isFilteredFeed
                clearItems()
            
            default:
                break
        }
    }
    
    // MARK: - Internal helpers
    
    fileprivate func handleItems(_ newItems: [Content], withLoadingType loadingType: PaginatedLoadingType) {
        switch loadingType {
            case .newer:
                let newItems = createNewItemsArray(newItems)
                
                if stashingEnabled {
                    stashedItems.append(contentsOf: newItems)
                    delegate?.chatFeedDataSource(self, didStashItems: newItems)
                }
                else {
                    unstashedItems.append(contentsOf: newItems)
                    delegate?.chatFeedDataSource(self, didLoadItems: newItems, loadingType: .newer)
                }
                
            case .older:
                let newItems = createNewItemsArray(newItems)
                unstashedItems = newItems + unstashedItems
                delegate?.chatFeedDataSource(self, didLoadItems: newItems, loadingType: .older)
                
            case .refresh:
                let newItems = createNewItemsArray(newItems)
                unstashedItems = newItems
                stashedItems = []
                delegate?.chatFeedDataSource(self, didLoadItems: newItems, loadingType: .refresh)
        }
    }
    fileprivate func createNewItemsArray(_ contents: [Content]) -> [ChatFeedContent] {
        guard let width = delegate?.chatFeedItemWidth else {
            return []
        }
        
        return contents.flatMap(){ content in
            ChatFeedContent(content: content, width: width, dependencyManager: dependencyManager)
        }
    }
    
    fileprivate func clearItems() {
        unstashedItems = []
        stashedItems = []
        delegate?.chatFeedDataSource(self, didLoadItems: [], loadingType: .refresh)
    }
    
    // MARK: - ForumEventSender
    
    weak var nextSender: ForumEventSender?
    
    // MARK: - ChatFeedNetworkDataSourceType
    
    weak var delegate: ChatFeedDataSourceDelegate?
    
    // MARK: - UICollectionViewDataSource
    
    let sizingCell = ChatFeedMessageCell(frame: CGRect.zero)
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems(for: collectionView, in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cellForItem(for: collectionView, at: indexPath)
        cell.showsReplyButton = shouldShowReplyButtons
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, desiredCellSizeAt indexPath: IndexPath) -> CGSize {
        return desiredCellSize(for: collectionView, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            return CollectionLoadingView.dequeue(from: collectionView, forSupplementaryViewKind: kind, at: indexPath)
        }
        
        assertionFailure("Unsupported supplementary view kind requested in ChatFeedDataSource.")
        return UICollectionReusableView()
    }
}
