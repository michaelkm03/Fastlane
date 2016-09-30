//
//  ChatFeed.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

private struct Constants {
    static let scrolledToBottomTolerance = CGFloat(5.0)
}

protocol ChatFeed: class, ForumEventSender, ForumEventReceiver {
    var nextSender: ForumEventSender? { get set }
    var delegate: ChatFeedDelegate? { get set }
    var dependencyManager: VDependencyManager! { get set }
    
    var newItemsController: NewItemsController? { get }
    var collectionView: UICollectionView! { get }
    var chatInterfaceDataSource: ChatInterfaceDataSource { get }
    
    // MARK: - Managing insets
    
    var addedTopInset: CGFloat { get set }
    var addedBottomInset: CGFloat { get set }
}

// MARK: - ChatFeedDelegate

protocol ChatFeedDelegate: class {
    func chatFeed(_ chatFeed: ChatFeed, didSelectUserWithID userID: User.ID)
    func chatFeed(_ chatFeed: ChatFeed, didSelect chatFeedContent: ChatFeedContent)
    func chatFeed(_ chatFeed: ChatFeed, didLongPress chatFeedContent: ChatFeedContent)
    func chatFeed(_ chatFeed: ChatFeed, didSelectFailureButtonFor chatFeedContent: ChatFeedContent)
    func chatFeed(_ chatFeed: ChatFeed, didSelectReplyButtonFor chatFeedContent: ChatFeedContent)
    func chatFeed(_ chatFeed: ChatFeed, didToggleLikeFor content: ChatFeedContent, completion: (() -> Void))
    func chatFeed(_ chatFeed: ChatFeed, didScroll scrollView: UIScrollView)
    func chatFeed(_ chatFeed: ChatFeed, willBeginDragging scrollView: UIScrollView)
    func chatFeed(_ chatFeed: ChatFeed, willEndDragging scrollView: UIScrollView, withVelocity velocity: CGPoint)
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
    func handleNewItems(_ newItems: [ChatFeedContent], loadingType: PaginatedLoadingType, newPendingContentCount: Int = 0, removedPendingContentIndices: [Int] = [], completion: (() -> Void)? = nil) {
        guard newItems.count > 0 || newPendingContentCount != 0 || removedPendingContentIndices.count > 0 || loadingType == .refresh else {
            return
        }
        
        if loadingType == .refresh {
            newItemsController?.hide()
        }
        
        let collectionView = self.collectionView!
        let wasScrolledToBottom = collectionView.isScrolledToBottom(withTolerance: Constants.scrolledToBottomTolerance)
        let oldPendingItemCount = max(0, chatInterfaceDataSource.pendingItems.count - newPendingContentCount)
        let insertingAbovePendingContent = oldPendingItemCount > 0 && newPendingContentCount <= 0

        /// Disabling animations so we can roll our own insertion animation.
        UIView.performWithoutAnimation { [weak self] in
            self?.updateCollectionView(with: newItems, loadingType: loadingType, newPendingContentCount: newPendingContentCount, removedPendingContentIndices: removedPendingContentIndices) {
                collectionView.collectionViewLayout.invalidateLayout()

                // If we loaded newer items and we were scrolled to the bottom, or if we refreshed the feed, scroll down to
                // reveal the new content.
                if (loadingType == .newer && wasScrolledToBottom) || loadingType == .refresh {
                    // Animation disabled when inserting above pending items because it causes the pending items to warp
                    // past the bottom and scroll back up. This could use some work to make the transition better.
                    collectionView.scrollToBottom(animated: loadingType != .refresh && !insertingAbovePendingContent)
                }
                
                completion?()
            }
        }
    }
    
    fileprivate func updateCollectionView(with newItems: [ChatFeedContent], loadingType: PaginatedLoadingType, newPendingContentCount: Int, removedPendingContentIndices: [Int], completion: @escaping () -> Void) {
        let collectionView = self.collectionView!
        let unstashedItemCount = chatInterfaceDataSource.unstashedItems.count
        let oldUnstashedItemCount = unstashedItemCount - newItems.count
        let itemCount = chatInterfaceDataSource.itemCount
        
        // The collection view's layout information is guaranteed to be updated properly in the completion handler
        // of this method, which allows us to properly manage scrolling.
        collectionView.performBatchUpdates({
            switch loadingType {
                case .newer:
                    collectionView.insertItems(at: (0 ..< newItems.count).map {
                        IndexPath(item: oldUnstashedItemCount + $0, section: 0)
                    })
                
                case .older:
                    if let layout = collectionView.collectionViewLayout as? ChatFeedCollectionViewLayout {
                        layout.contentSizeWhenInsertingAbove = collectionView.contentSize
                    }
                    else {
                        assertionFailure("Chat feed's collection view did not have the required layout type ChatFeedCollectionViewLayout.")
                    }
                    
                    collectionView.insertItems(at: (0 ..< newItems.count).map {
                        IndexPath(item: $0, section: 0)
                    })
                
                case .refresh:
                    // Calling reloadData in here causes a crash
                    collectionView.reloadSections(IndexSet(integer: 0))
            }
            
            collectionView.insertItems(at: (0 ..< newPendingContentCount).map {
                IndexPath(item: itemCount - 1 - $0, section: 0)
            })
            
            collectionView.deleteItems(at: removedPendingContentIndices.map {
                
                IndexPath(item: oldUnstashedItemCount + $0, section: 0)
            })
        }, completion: { _ in
            completion()
        })
    }
    
    /// Removes the given content from the data source and from the collection view.
    func remove(_ item: ChatFeedContent) {
        guard let index = chatInterfaceDataSource.unstashedItems.index(where: { item.content.id == $0.content.id }) else {
            assertionFailure("Tried to remove content from chat feed, but the chat feed didn't contain that content.")
            return
        }
        
        chatInterfaceDataSource.removeUnstashedItem(at: index)
        let item = IndexPath(item: index, section: 0)
        collectionView.deleteItems(at: [item])
    }
}
