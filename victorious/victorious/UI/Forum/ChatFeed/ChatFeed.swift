//
//  ChatFeed.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ChatFeed: class, ForumEventReceiver, ForumEventSender {
    
    weak var delegate: ChatFeedDelegate? { get set }
    
    weak var nextSender: ForumEventSender? { get set }
    
    var dependencyManager: VDependencyManager! { get set }
    
    // MARK: - Layout
    
    func setTopInset(value: CGFloat)
    
    func setBottomInset(value: CGFloat)
    
    var newItemsController: NewItemsController? { get }
    var collectionView: UICollectionView! { get }
    var chatDataSource: ChatInterfaceDataSource { get }
}

extension ChatFeed {
    func handleNewItems(newItems: [ChatFeedContent], loadingType: PaginatedLoadingType, completion: (() -> Void)? = nil) {
        guard newItems.count > 0 || loadingType == .refresh else {
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
        
        updateCollectionView(with: newItems, loadingType: loadingType) {
            collectionView.collectionViewLayout.invalidateLayout()
            
            CATransaction.commit()
            
            // If we loaded newer items and we were scrolled to the bottom, or if we refreshed the feed, scroll down to
            // reveal the new content.
            if (loadingType == .newer && wasScrolledToBottom) || loadingType == .refresh {
                collectionView.setContentOffset(collectionView.v_bottomOffset, animated: loadingType != .refresh)
            }
            
            completion?()
        }
    }
    
    func updateCollectionView(with newItems: [ChatFeedContent], loadingType: PaginatedLoadingType, completion: () -> Void) {
        if loadingType == .refresh {
            collectionView.reloadData()
            completion()
        }
        else {
            let collectionView = self.collectionView
            
            // The collection view's layout information is guaranteed to be updated properly in the completion handler
            // of this method, which allows us to properly manage scrolling. We can't call `reloadData` in this method,
            // though, so we have to do that separately.
            collectionView.performBatchUpdates({
                switch loadingType {
                case .newer:
                    let previousCount = self.chatDataSource.visibleItems.count - newItems.count
                    
                    collectionView.insertItemsAtIndexPaths((0 ..< newItems.count).map {
                        NSIndexPath(forItem: previousCount + $0, inSection: 0)
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
                }, completion: { _ in
                    completion()
            })
        }
    }
}

protocol ChatFeedDelegate: class {
    
    func chatFeed(chatFeed: ChatFeed, didSelectUserWithUserID userID: Int)
    
    func chatFeed(chatFeed: ChatFeed, didSelectContent content: ContentModel)
}
