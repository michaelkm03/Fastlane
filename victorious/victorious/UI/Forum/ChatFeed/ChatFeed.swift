//
//  ChatFeed.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ChatFeed: class, ForumEventSender, ForumEventReceiver {
    var nextSender: ForumEventSender? { get set }
    var delegate: ChatFeedDelegate? { get set }
    var dependencyManager: VDependencyManager! { get set }
    
    var newItemsController: NewItemsController? { get }
    var collectionView: UICollectionView! { get }
    var chatInterfaceDataSource: ChatInterfaceDataSource { get }
    
    // MARK: - Layout
    
    func setTopInset(value: CGFloat)
    func setBottomInset(value: CGFloat)
}

protocol ChatFeedDelegate: class {
    func chatFeed(chatFeed: ChatFeed, didSelectUserWithUserID userID: Int)
    func chatFeed(chatFeed: ChatFeed, didSelectContent content: ChatFeedContent)
    func chatFeed(chatFeed: ChatFeed, didSelectFailureButtonForContent content: ChatFeedContent)
    
    func chatFeed(chatFeed: ChatFeed, didScroll scrollView: UIScrollView)
    func chatFeed(chatFeed: ChatFeed, willBeginDragging scrollView: UIScrollView)
    func chatFeed(chatFeed: ChatFeed, willEndDragging scrollView: UIScrollView, withVelocity velocity: CGPoint)
    
    func publisher(for chatFeed: ChatFeed) -> ContentPublisher?
}

extension ChatFeed {
    var delegate: ChatFeedDelegate? {
        get {
            return nil
        }
        set {}
    }
    
    var newItemsController: NewItemsController? {
        return nil
    }
    
    /// Updates the collection view with the given set of new items, inserting or reloading depending on the
    /// `loadingType`.
    ///
    /// The items are expected to have already been updated in the data source.
    ///
    /// If pending content has been added or removed, the added count or the indices of the removed items should be
    /// passed in via `newPendingContentCount` and `removedPendingContentIndices`.
    ///
    func handleNewItems(newItems: [ChatFeedContent], loadingType: PaginatedLoadingType, newPendingContentCount: Int = 0, removedPendingContentIndices: [Int] = [], completion: (() -> Void)? = nil) {
        guard newItems.count > 0 || newPendingContentCount != 0 || removedPendingContentIndices.count > 0 || loadingType == .refresh else {
            return
        }
        
        if loadingType == .refresh {
            newItemsController?.hide()
        }
        
        // Disable UICollectionView insertion animation.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let collectionView = self.collectionView
        let wasScrolledToBottom = collectionView.v_isScrolledToBottom
        let oldPendingItemCount = max(0, chatInterfaceDataSource.pendingItems.count - newPendingContentCount)
        let insertingAbovePendingContent = oldPendingItemCount > 0 && newPendingContentCount <= 0
        
        updateCollectionView(with: newItems, loadingType: loadingType, newPendingContentCount: newPendingContentCount, removedPendingContentIndices: removedPendingContentIndices) {
            collectionView.collectionViewLayout.invalidateLayout()
            CATransaction.commit()
            
            // If we loaded newer items and we were scrolled to the bottom, or if we refreshed the feed, scroll down to
            // reveal the new content.
            if (loadingType == .newer && wasScrolledToBottom) || loadingType == .refresh {
                // Animation disabled when inserting above pending items because it causes the pending items to warp
                // past the bottom and scroll back up. This could use some work to make the transition better.
                collectionView.setContentOffset(collectionView.v_bottomOffset, animated: loadingType != .refresh && !insertingAbovePendingContent)
            }
            
            completion?()
        }
    }
    
    private func updateCollectionView(with newItems: [ChatFeedContent], loadingType: PaginatedLoadingType, newPendingContentCount: Int, removedPendingContentIndices: [Int], completion: () -> Void) {
        let collectionView = self.collectionView
        let visibleItemCount = chatInterfaceDataSource.visibleItems.count
        let oldVisibleItemCount = visibleItemCount - newItems.count
        let itemCount = chatInterfaceDataSource.itemCount
        
        // The collection view's layout information is guaranteed to be updated properly in the completion handler
        // of this method, which allows us to properly manage scrolling. We can't call `reloadData` in this method,
        // though, so we have to do that separately.
        collectionView.performBatchUpdates({
            switch loadingType {
            case .newer:
                collectionView.insertItemsAtIndexPaths((0 ..< newItems.count).map {
                    NSIndexPath(forItem: oldVisibleItemCount + $0, inSection: 0)
                    })
                
            case .older:
                if let layout = collectionView.collectionViewLayout as? ChatFeedCollectionViewLayout {
                    layout.contentSizeWhenInsertingAbove = collectionView.contentSize
                }
                else {
                    assertionFailure("Chat feed's collection view did not have the required layout type ChatFeedCollectionViewLayout.")
                }
                
                collectionView.insertItemsAtIndexPaths((0 ..< newItems.count).map {
                    NSIndexPath(forItem: $0, inSection: 0)
                    })
                
            case .refresh:
                // Calling reloadData in here causes a crash
                collectionView.reloadSections(NSIndexSet(index: 0))
            }
            
            collectionView.insertItemsAtIndexPaths((0 ..< newPendingContentCount).map {
                NSIndexPath(forItem: itemCount - 1 - $0, inSection: 0)
                })
            
            collectionView.deleteItemsAtIndexPaths(removedPendingContentIndices.map {
                NSIndexPath(forItem: oldVisibleItemCount + $0, inSection: 0)
                })
            }, completion: { _ in
                completion()
        })
    }
}
