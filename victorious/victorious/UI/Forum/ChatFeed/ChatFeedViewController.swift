//
//  ChatFeedViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

class ChatFeedViewController: UIViewController, ChatFeed, ChatFeedDataSourceDelegate, UICollectionViewDelegateFlowLayout, NewItemsControllerDelegate, ChatFeedMessageCellDelegate {
    fileprivate struct Layout {
        fileprivate static let bottomMargin: CGFloat = 20.0
    }
    
    fileprivate lazy var dataSource: ChatFeedDataSource = {
        return ChatFeedDataSource(dependencyManager: self.dependencyManager)
    }()
    
    fileprivate lazy var focusHelper: VCollectionViewStreamFocusHelper = {
        return VCollectionViewStreamFocusHelper(collectionView: self.collectionView)
    }()
    
    fileprivate var scrollPaginator = ScrollPaginator()
    
    // MARK: - ChatFeed
    
    weak var delegate: ChatFeedDelegate?
    var dependencyManager: VDependencyManager!
    
    @IBOutlet fileprivate(set) weak var collectionView: UICollectionView!
    @IBOutlet fileprivate(set) var newItemsController: NewItemsController?
    
    var chatInterfaceDataSource: ChatInterfaceDataSource {
        return dataSource
    }
    
    // MARK: - Managing insets
    
    @IBOutlet fileprivate var collectionViewBottom: NSLayoutConstraint!
    
    var addedTopInset = CGFloat(0.0) {
        didSet {
            updateInsets()
        }
    }
    
    var addedBottomInset = CGFloat(0.0) {
        didSet {
            updateInsets()
            collectionViewBottom.constant = addedBottomInset
            collectionView.superview?.layoutIfNeeded()
        }
    }
    
    fileprivate func updateInsets() {
        // Always invalidate layout before adjusting insets as they impact the location of the spinner and will,
        // otherwise, cause a crash.
        self.collectionView.collectionViewLayout.invalidateLayout()
        
        if collectionView.numberOfItems(inSection: 0) == 0 {
            // When there are no items, we display a centered activity indicator, which becomes misaligned if there are
            // any insets, so we zero them out while in this state.
            collectionView.contentInset = UIEdgeInsets.zero
        }
        else {
            // The added bottom inset value actually needs to get added to the top inset because of the way the bottom
            // inset works. Instead of adjusting the bottom content inset, the added bottom inset will shift the entire
            // collection view upward in its container without adjusting its height. This fixes the scrolling behavior when
            // the keyboard appears, but causes the top of the collection view to be clipped. Increasing the top inset
            // keeps all of the content accessible by pushing it down below the clipped portion of the collection view.
            collectionView.contentInset = UIEdgeInsets(
                top: addedTopInset + addedBottomInset,
                left: 0.0,
                bottom: Layout.bottomMargin,
                right: 0.0
            )
            
            UIView.performWithoutAnimation {
                self.collectionView.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Managing the loading view
    
    /// The most recently-displayed loading view. We need this because our loading state gets set after the loading
    /// view displays, so we have to set the visibility of the activity indicator after the fact.
    fileprivate var loadingView: CollectionLoadingView?
    
    /// Whether or not the loading view above the chat messages is enabled.
    fileprivate var loadingViewEnabled = false {
        didSet {
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    /// Whether or not we're currently loading messages, which is controlled by the `setLoadingContent` forum event.
    fileprivate var isLoading = false {
        didSet {
            collectionView.collectionViewLayout.invalidateLayout()
            updateLoadingView()
        }
    }
    
    fileprivate func updateLoadingView() {
        loadingView?.isLoading = loadingViewEnabled && isLoading
    }
    
    // MARK: - ForumEventReceiver
    
    var childEventReceivers: [ForumEventReceiver] {
        return [dataSource]
    }
    
    func receive(_ event: ForumEvent) {
        switch event {
            case .setChatActivityIndicatorEnabled(let enabled): loadingViewEnabled = enabled
            case .setLoadingContent(let isLoading, let loadingType): self.isLoading = isLoading && loadingType.showsLoadingState
            default: break
        }
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
        
        edgesForExtendedLayout = UIRectEdge()
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        updateInsets()
        
        dataSource.delegate = self
        dataSource.registerCells(for: collectionView)
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        dataSource.nextSender = self
        
        newItemsController?.dependencyManager = dependencyManager
        newItemsController?.delegate = self
        newItemsController?.hide(animated: false)
        
        scrollPaginator.loadItemsAbove = { [weak self] in
            self?.send(.loadOldContent)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.unstash()
        focusHelper.updateFocus()
        startTimestampUpdate()

        // Needed to update the like state and count
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dataSource.stashingEnabled = true
        focusHelper.endFocusOnAllCells()
        stopTimestampUpdate()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let messageCell = cell as! ChatFeedMessageCell
        messageCell.delegate = self
        messageCell.startDisplaying()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! ChatFeedMessageCell).stopDisplaying()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return dataSource.collectionView(collectionView, desiredCellSizeAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if let loadingView = view as? CollectionLoadingView {
            loadingView.color = dependencyManager.activityIndicatorColor
            self.loadingView = loadingView
            updateLoadingView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard loadingViewEnabled else {
            return CGSize.zero
        }
        
        var size = CollectionLoadingView.preferredSize(in: collectionView.bounds)
        
        if collectionView.numberOfItems(inSection: 0) == 0 {
            // If the collection view is empty, we want to center the activity indicator vertically, so we size it to
            // the collection view's height.
            size.height = collectionView.bounds.height - collectionView.contentInset.vertical
        }
        
        return size
    }
    
    // MARK: - ChatFeedDataSourceDelegate
    
    func chatFeedDataSource(_ dataSource: ChatFeedDataSource, didLoadItems newItems: [ChatFeedContent], loadingType: PaginatedLoadingType) {
        let removedPendingContentIndices = removePendingContent(newItems)
        handleNewItems(newItems, loadingType: loadingType, removedPendingContentIndices: removedPendingContentIndices)
        updateInsets()
    }
    
    func chatFeedDataSource(_ dataSource: ChatFeedDataSource, didStashItems stashedItems: [ChatFeedContent]) {
        let itemsContainOtherUserMessage = stashedItems.contains { !$0.content.wasCreatedByCurrentUser }
        
        if itemsContainOtherUserMessage {
            // Update stash count and show stash counter.
            newItemsController?.count = dataSource.stashedItems.count
            newItemsController?.show()
        }
    }
    
    func chatFeedDataSource(_ dataSource: ChatFeedDataSource, didUnstashItems unstashedItems: [ChatFeedContent]) {
        newItemsController?.hide()
        
        let removedPendingContentIndices = removePendingContent(unstashedItems)
        
        handleNewItems(unstashedItems, loadingType: .newer, removedPendingContentIndices: removedPendingContentIndices) { [weak self] in
            self?.collectionView.scrollToBottom(animated: true)
        }
        
        updateInsets()
    }
    
    var chatFeedItemWidth: CGFloat {
        return collectionView.bounds.width
    }
    
    func pendingItems(for chatFeedDataSource: ChatFeedDataSource) -> [ChatFeedContent] {
        return delegate?.publisher(for: self)?.pendingItems ?? []
    }
    
    fileprivate func removePendingContent(_ contentToRemove: [ChatFeedContent]) -> [Int] {
        guard let publisher = delegate?.publisher(for: self) else {
            return []
        }
        
        if publisher.pendingItems.isEmpty || contentToRemove.isEmpty {
            return []
        }
        
        return publisher.remove(contentToRemove)
    }
    
    // MARK: - ChatFeedMessageCellDelegate
    
    func messageCellDidSelectAvatarImage(_ messageCell: ChatFeedMessageCell) {
        guard let userID = messageCell.chatFeedContent?.content.author?.id else {
            return
        }
        
        delegate?.chatFeed(self, didSelectUserWithID: userID)
    }
    
    func messageCellDidSelectMedia(_ messageCell: ChatFeedMessageCell) {
        guard let content = messageCell.chatFeedContent else {
            return
        }
        
        delegate?.chatFeed(self, didSelect: content)
    }
    
    func messageCellDidLongPressContent(_ messageCell: ChatFeedMessageCell) {
        guard let content = messageCell.chatFeedContent else {
            return
        }
        
        delegate?.chatFeed(self, didLongPress: content)
    }

    func messageCellDidToggleLikeContent(_ messageCell: ChatFeedMessageCell, completion: (() -> Void)) {
        guard let content = messageCell.chatFeedContent else {
            return
        }

        delegate?.chatFeed(self, didToggleLikeFor: content, completion: completion)
    }

    func messageCellDidSelectFailureButton(_ messageCell: ChatFeedMessageCell) {
        guard let content = messageCell.chatFeedContent else {
            return
        }
        
        delegate?.chatFeed(self, didSelectFailureButtonFor: content)
    }
    
    func messageCellDidSelectReplyButton(_ messageCell: ChatFeedMessageCell) {
        guard let content = messageCell.chatFeedContent else {
            return
        }
        
        delegate?.chatFeed(self, didSelectReplyButtonFor: content)
        dependencyManager.trackButtonEvent(.tap, forTrackingKey: "reply.tracking")
    }
    
    func messageCell(_ messageCell: ChatFeedMessageCell, didSelectLinkURL url: URL) {
        Router(originViewController: self, dependencyManager: dependencyManager).navigate(
            to: DeeplinkDestination(url: url),
            from: nil
        )
    }
    
    // MARK: - UIScrollViewDelegate
    
    var unstashingViaScrollingIsEnabled = true
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollPaginator.scrollViewDidScroll(scrollView)
        
        if scrollView.isScrolledToBottom() {
            if unstashingViaScrollingIsEnabled {
                dataSource.unstash()
            }
            
            dataSource.stashingEnabled = false
        }
        else {
            dataSource.stashingEnabled = true
        }
        
        focusHelper.updateFocus()
        
        delegate?.chatFeed(self, didScroll: scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.chatFeed(self, willBeginDragging: scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.chatFeed(self, willEndDragging: scrollView, withVelocity: velocity)
    }
    
    // MARK: - Timestamp update timer
    
    static let timestampUpdateInterval: TimeInterval = 1.0
    
    fileprivate var timerManager: VTimerManager?
    
    fileprivate func stopTimestampUpdate() {
        timerManager?.invalidate()
        timerManager = nil
    }
    
    fileprivate func startTimestampUpdate() {
        guard timerManager == nil else {
            return
        }
        
        timerManager = VTimerManager.add(
            withTimeInterval: ChatFeedViewController.timestampUpdateInterval,
            target: self,
            selector: #selector(onTimerTick),
            userInfo: nil,
            repeats: true,
            to: RunLoop.main,
            withRunMode: RunLoopMode.commonModes.rawValue
        )
        
        onTimerTick()
    }
    
    fileprivate dynamic func onTimerTick() {
        dataSource.updateTimestamps(in: collectionView)
    }
}

private extension PaginatedLoadingType {
    var showsLoadingState: Bool {
        switch self {
            case .newer: return false
            case .older, .refresh: return true
        }
    }
}

private extension VDependencyManager {
    var activityIndicatorColor: UIColor? {
        return color(forKey: "color.message.text")
    }
}
