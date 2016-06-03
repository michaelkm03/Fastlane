//
//  ChatFeedViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ChatFeedViewController: UIViewController, ChatFeed, ChatFeedDataSourceDelegate, UICollectionViewDelegateFlowLayout, VScrollPaginatorDelegate, NewItemsControllerDelegate, ChatFeedMessageCellDelegate {
    private lazy var dataSource: ChatFeedDataSource = {
        return ChatFeedDataSource(dependencyManager: self.dependencyManager)
    }()
    
    private struct Layout {
        private static let bottomMargin: CGFloat = 20.0
        private static let topMargin: CGFloat = 64.0
    }
    
    private var edgeInsets = UIEdgeInsets(top: Layout.topMargin, left: 0.0, bottom: Layout.bottomMargin, right: 0.0)
    
    var dependencyManager: VDependencyManager!
    
    private lazy var focusHelper: VCollectionViewStreamFocusHelper = {
        return VCollectionViewStreamFocusHelper(collectionView: self.collectionView)
    }()
    
    private let scrollPaginator = VScrollPaginator()
    
    // Used to create a temporary window where immediate re-stashing is disabled after unstashing
    private var canStashNewItems: Bool = true
    
    @IBOutlet private var newItemsController: NewItemsController!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewBottom: NSLayoutConstraint!
    
    //MARK: - ChatFeed
    
    weak var delegate: ChatFeedDelegate?
    
    func setTopInset(value: CGFloat) {
        edgeInsets.top = value + Layout.topMargin
    }
    
    func setBottomInset(value: CGFloat) {
        collectionViewBottom.constant = value
        collectionView.superview?.layoutIfNeeded()
    }
    
    // MARK: - ForumEventReceiver
        
    var childEventReceivers: [ForumEventReceiver] {
        return [dataSource]
    }
    
    // MARK: - ForumEventSender
    
    weak var nextSender: ForumEventSender?
    
    // MARK: - NewItemsControllerDelegate
        
    func onNewItemsSelected() {
        dataSource.unstash()
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = .None
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        
        dataSource.delegate = self
        dataSource.registerCells(for: collectionView)
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        scrollPaginator.delegate = self
        
        dataSource.nextSender = self
        
        newItemsController.depedencyManager = dependencyManager
        newItemsController.delegate = self
        newItemsController.hide(animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.unstash()
        focusHelper.updateFocus()
        startTimestampUpdate()
        paginatedDataSource.unstashAll()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        dataSource.stashingEnabled = true
        focusHelper.endFocusOnAllCells()
        stopTimestampUpdate()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let messageCell = cell as! ChatFeedMessageCell
        messageCell.delegate = self
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return dataSource.collectionView(collectionView, sizeForItemAtIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        // If there isn't enough content to fill the screen, push it down to the bottom.
        var adjustedInsets = edgeInsets
        adjustedInsets.top += max(0.0, collectionView.bounds.height - collectionView.contentSize.height)
        return adjustedInsets
    }
    
    // MARK: - ChatFeedDataSourceDelegate
    
    func chatFeedDataSource(dataSource: ChatFeedDataSource, didLoadItems newItems: [ContentModel], loadingType: PaginatedLoadingType) {
        handleNewItems(newItems, loadingType: loadingType)
    }
    
    func chatFeedDataSource(dataSource: ChatFeedDataSource, didStashItems stashedItems: [ContentModel]) {
        let itemsContainCurrentUserMessage = stashedItems.contains {
            $0.authorModel.id == VCurrentUser.user()?.remoteId.integerValue
        }
        
        if itemsContainCurrentUserMessage {
            // Unstash if we got a message from the current user.
            dataSource.unstash()
        }
        else if stashedItems.count > 0 {
            // Update stash count and show stash counter.
            newItemsController.count = dataSource.stashedItems.count
            newItemsController.show()
        }
    }
    
    func chatFeedDataSource(dataSource: ChatFeedDataSource, didUnstashItems unstashedItems: [ContentModel]) {
        newItemsController.hide()
        
        handleNewItems(unstashedItems, loadingType: .newer) { [weak self] in
            if self?.collectionView.v_isScrolledToBottom == false {
                self?.collectionView.v_scrollToBottomAnimated(true)
            }
        }
    }
    
    func chatFeedDataSource(dataSource: ChatFeedDataSource, didPurgeItems purgedItems: [ContentModel]) {
        collectionView.deleteItemsAtIndexPaths((0 ..< purgedItems.count).map {
            NSIndexPath(forItem: $0, inSection: 0)
        })
    }
    
    private func handleNewItems(newItems: [ContentModel], loadingType: PaginatedLoadingType, completion: (() -> Void)? = nil) {
        guard newItems.count > 0 else {
            return
        }
        
        // Disable UICollectionView insertion animation.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let collectionView = self.collectionView
        let bottomOffset = collectionView.contentSize.height - collectionView.contentOffset.y
        let wasScrolledToBottom = collectionView.v_isScrolledToBottom
        
        // The collection view's layout information is guaranteed to be updated properly in the completion handler of
        // this method, which allows us to properly manage scrolling.
        collectionView.performBatchUpdates({
            switch loadingType {
            case .newer:
                let previousCount = self.dataSource.unstashedItems.count - newItems.count
                
                collectionView.insertItemsAtIndexPaths((0 ..< newItems.count).map {
                    NSIndexPath(forItem: previousCount + $0, inSection: 0)
                })
            
            case .older:
                collectionView.insertItemsAtIndexPaths((0 ..< newItems.count).map {
                    NSIndexPath(forItem: $0, inSection: 0)
                })
            
            case .refresh:
                collectionView.reloadData()
            }
        }, completion: { _ in
            // If we loaded older items, maintain the previous scroll position.
            if loadingType == .older {
                collectionView.contentOffset = CGPoint(x: 0.0, y: collectionView.contentSize.height - bottomOffset)
            }
            
            collectionView.collectionViewLayout.invalidateLayout()
            
            CATransaction.commit()
            
            // If we loaded newer items and we were scrolled to the bottom, scroll down to reveal the new content.
            if (loadingType == .newer || loadingType == .refresh) && wasScrolledToBottom {
                collectionView.setContentOffset(collectionView.v_bottomOffset, animated: true)
            }
            
            completion?()
        })
    }
    
    // MARK: - VScrollPaginatorDelegate
    
    func shouldLoadPreviousPage() {
        send(.loadOldContent)
    }
    
    // MARK: - ChatFeedMessageCellDelegate
    
    func messageCellDidSelectAvatarImage(messageCell: ChatFeedMessageCell) {
        guard let userID = messageCell.content?.authorModel.id else {
            return
        }
        
        delegate?.chatFeed(self, didSelectUserWithUserID: userID)
    }
    
    func messageCellDidSelectMedia(messageCell: ChatFeedMessageCell) {
        guard let content = messageCell.content else {
            return
        }
        
        delegate?.chatFeed(self, didSelectContent: content)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollPaginator.scrollViewDidScroll(scrollView)
        
        if scrollView.v_isScrolledToBottom {
            dataSource.unstash()
            dataSource.stashingEnabled = false
        } else {
            dataSource.stashingEnabled = true
        }
        
        focusHelper.updateFocus()
    }
    
    // MARK: - Timestamp update timer
    
    static let timestampUpdateInterval: NSTimeInterval = 1.0
    
    private var timerManager: VTimerManager?
    
    private func stopTimestampUpdate() {
        timerManager?.invalidate()
        timerManager = nil
    }
    
    private func startTimestampUpdate() {
        guard timerManager == nil else {
            return
        }
        
        timerManager = VTimerManager.addTimerManagerWithTimeInterval(
            ChatFeedViewController.timestampUpdateInterval,
            target: self,
            selector: #selector(onTimerTick),
            userInfo: nil,
            repeats: true,
            toRunLoop: NSRunLoop.mainRunLoop(),
            withRunMode: NSRunLoopCommonModes
        )
        
        onTimerTick()
    }
    
    private dynamic func onTimerTick() {
        dataSource.updateTimestamps(for: collectionView)
    }
}
