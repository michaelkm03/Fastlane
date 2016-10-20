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
        
        NotificationCenter.default.addObserver(self, selector: #selector(mainFeedFilterDidChange), name: NSNotification.Name(rawValue: RESTForumNetworkSource.updateStreamURLNotification), object: nil)
    }
    
    // MARK: - Dependency manager
    
    let dependencyManager: VDependencyManager
    
    // MARK: - Configuration
    
    /// When enabled, new items will be added to `stashedItems` rather than `unstashedItems`.
    var stashingEnabled = false
    
    /// Whether or not the pending items from the delegate should be displayed.
    private var shouldShowPendingItems: Bool {
        return !feedIsFiltered || feedIsChatRoom
    }
    
    /// Whether or not reply buttons in chat cells should be displayed.
    var shouldShowReplyButtons: Bool {
        return !feedIsFiltered || feedIsChatRoom
    }
    
    private var feedIsFiltered = false
    
    private var feedIsChatRoom = false
    
    // MARK: - Managing content
    
    private(set) var unstashedItems = [ChatFeedContent]()
    private(set) var stashedItems = [ChatFeedContent]()
    
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
    
    // MARK: - Notifications
    
    private dynamic func mainFeedFilterDidChange(notification: NSNotification) {
        let selectedItem = notification.userInfo?["selectedItem"] as? ListMenuSelectedItem
        feedIsChatRoom = selectedItem?.chatRoomID != nil
    }
    
    // MARK: - ForumEventReceiver
    
    let childEventReceivers = [ForumEventReceiver]()
    
    func receive(_ event: ForumEvent) {
        switch event {
            case .handleContent(let newItems, let loadingType):
                handleItems(newItems, withLoadingType: loadingType)
            
            case .filterContent(let path):
                feedIsFiltered = path != nil
                clearItems()
            
            default:
                break
        }
    }
    
    // MARK: - Internal helpers
    
    private func handleItems(_ newItems: [Content], withLoadingType loadingType: PaginatedLoadingType) {
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
    private func createNewItemsArray(_ contents: [Content]) -> [ChatFeedContent] {
        guard let width = delegate?.chatFeedItemWidth else {
            return []
        }
        
        return contents.flatMap(){ content in
            ChatFeedContent(content: content, width: width, dependencyManager: dependencyManager)
        }
    }
    
    private func clearItems() {
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
        let replyButtonEnabled = VCurrentUser.user?.accessLevel.isCreator == true ? dependencyManager.creatorReplyButtonEnabled : dependencyManager.userReplyButtonEnabled
        cell.showsReplyButton = shouldShowReplyButtons && replyButtonEnabled
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

private extension VDependencyManager {
    var creatorReplyButtonEnabled: Bool {
        return bool(for: "creator.show.reply.button") ?? false
    }
    
    var userReplyButtonEnabled: Bool {
        return bool(for: "user.show.reply.button") ?? false
    }
}
