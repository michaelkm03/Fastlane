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
    func chatFeed(chatFeed: ChatFeed, didSelectContent content: ContentModel)
    func chatFeed(chatFeed: ChatFeed, didSelectFailureButtonForContent content: ContentModel)
    
    func chatFeed(chatFeed: ChatFeed, didScroll scrollView: UIScrollView)
    
    func chatFeed(chatFeed: ChatFeed, willBeginDragging scrollView: UIScrollView)
    
    func chatFeed(chatFeed: ChatFeed, willEndDragging scrollView: UIScrollView, withVelocity velocity: CGPoint)
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
    /// If pending content has been added or removed, the change in count should be passed in as `pendingContentDelta`,
    /// which will adjust the number of inserted items accordingly.
    ///
    func handleNewItems(newItems: [ChatFeedContent], loadingType: PaginatedLoadingType, pendingContentDelta: Int = 0, completion: (() -> Void)? = nil) {
        guard newItems.count > 0 || pendingContentDelta != 0 || loadingType == .refresh else {
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
        let oldPendingItemCount = max(0, chatInterfaceDataSource.pendingItems.count - pendingContentDelta)
        let insertingAbovePendingContent = oldPendingItemCount > 0 && pendingContentDelta <= 0
        
        updateCollectionView(with: newItems, loadingType: loadingType, pendingContentDelta: pendingContentDelta) {
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
    
    private func updateCollectionView(with newItems: [ChatFeedContent], loadingType: PaginatedLoadingType, pendingContentDelta: Int, completion: () -> Void) {
        if loadingType == .refresh {
            collectionView.reloadData()
            completion()
        }
        else {
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
                        break
                }
                
                for index in 0 ..< abs(pendingContentDelta) {
                    if pendingContentDelta < 0 {
                        collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: oldVisibleItemCount + index, inSection: 0)])
                    }
                    else {
                        collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: itemCount - 1 - index, inSection: 0)])
                    }
                }
            }, completion: { _ in
                completion()
            })
        }
    }
}
