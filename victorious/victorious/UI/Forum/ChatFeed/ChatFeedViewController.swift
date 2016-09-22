//
//  ChatFeedViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ChatFeedViewController: UIViewController, ChatFeed, ChatFeedDataSourceDelegate, UICollectionViewDelegateFlowLayout, NewItemsControllerDelegate, ChatFeedMessageCellDelegate {
    private struct Layout {
        private static let bottomMargin: CGFloat = 20.0
    }
    
    private lazy var dataSource: ChatFeedDataSource = {
        return ChatFeedDataSource(dependencyManager: self.dependencyManager)
    }()
    
    private lazy var focusHelper: VCollectionViewStreamFocusHelper = {
        return VCollectionViewStreamFocusHelper(collectionView: self.collectionView)
    }()
    
    private var scrollPaginator = ScrollPaginator()
    
    // MARK: - ChatFeed
    
    weak var delegate: ChatFeedDelegate?
    var dependencyManager: VDependencyManager!
    
    @IBOutlet private(set) weak var collectionView: UICollectionView!
    @IBOutlet private(set) var newItemsController: NewItemsController?
    
    var chatInterfaceDataSource: ChatInterfaceDataSource {
        return dataSource
    }
    
    // MARK: - Managing insets
    
    @IBOutlet private var collectionViewBottom: NSLayoutConstraint!
    
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
    
    private func updateInsets() {
        // Always invalidate layout before adjusting insets as they impact the location of the spinner and will,
        // otherwise, cause a crash.
        self.collectionView.collectionViewLayout.invalidateLayout()
        
        if collectionView.numberOfItemsInSection(0) == 0 {
            // When there are no items, we display a centered activity indicator, which becomes misaligned if there are
            // any insets, so we zero them out while in this state.
            collectionView.contentInset = UIEdgeInsetsZero
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
    private var loadingView: CollectionLoadingView?
    
    /// Whether or not the loading view above the chat messages is enabled.
    private var loadingViewEnabled = false {
        didSet {
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    /// Whether or not we're currently loading messages, which is controlled by the `setLoadingContent` forum event.
    private var isLoading = false {
        didSet {
            collectionView.collectionViewLayout.invalidateLayout()
            updateLoadingView()
        }
    }
    
    private func updateLoadingView() {
        loadingView?.isLoading = loadingViewEnabled && isLoading
    }
    
    // MARK: - ForumEventReceiver
    
    var childEventReceivers: [ForumEventReceiver] {
        return [dataSource]
    }
    
    func receive(event: ForumEvent) {
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
        
        edgesForExtendedLayout = .None
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.unstash()
        focusHelper.updateFocus()
        startTimestampUpdate()

        // Needed to update the like state and count
        collectionView.reloadData()
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
        messageCell.startDisplaying()
    }
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        (cell as! ChatFeedMessageCell).stopDisplaying()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return dataSource.collectionView(collectionView, sizeForItemAtIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        if let loadingView = view as? CollectionLoadingView {
            loadingView.color = dependencyManager.activityIndicatorColor
            self.loadingView = loadingView
            updateLoadingView()
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard loadingViewEnabled else {
            return CGSize.zero
        }
        
        var size = CollectionLoadingView.preferredSize(in: collectionView.bounds)
        
        if collectionView.numberOfItemsInSection(0) == 0 {
            // If the collection view is empty, we want to center the activity indicator vertically, so we size it to
            // the collection view's height.
            size.height = collectionView.bounds.height - collectionView.contentInset.vertical
        }
        
        return size
    }
    
    // MARK: - ChatFeedDataSourceDelegate
    
    func chatFeedDataSource(dataSource: ChatFeedDataSource, didLoadItems newItems: [ChatFeedContent], loadingType: PaginatedLoadingType) {
        let removedPendingContentIndices = removePendingContent(newItems)
        handleNewItems(newItems, loadingType: loadingType, removedPendingContentIndices: removedPendingContentIndices)
        updateInsets()
    }
    
    func chatFeedDataSource(dataSource: ChatFeedDataSource, didStashItems stashedItems: [ChatFeedContent]) {
        let itemsContainOtherUserMessage = stashedItems.contains { !$0.content.wasCreatedByCurrentUser }
        
        if itemsContainOtherUserMessage {
            // Update stash count and show stash counter.
            newItemsController?.count = dataSource.stashedItems.count
            newItemsController?.show()
        }
    }
    
    func chatFeedDataSource(dataSource: ChatFeedDataSource, didUnstashItems unstashedItems: [ChatFeedContent]) {
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
    
    private func removePendingContent(contentToRemove: [ChatFeedContent]) -> [Int] {
        guard let publisher = delegate?.publisher(for: self) else {
            return []
        }
        
        if publisher.pendingItems.isEmpty || contentToRemove.isEmpty {
            return []
        }
        
        return publisher.remove(contentToRemove)
    }
    
    // MARK: - ChatFeedMessageCellDelegate
    
    func messageCellDidSelectAvatarImage(messageCell: ChatFeedMessageCell) {
        guard let userID = messageCell.chatFeedContent?.content.author?.id else {
            return
        }
        
        delegate?.chatFeed(self, didSelectUserWithID: userID)
    }
    
    func messageCellDidSelectMedia(messageCell: ChatFeedMessageCell) {
        guard let content = messageCell.chatFeedContent else {
            return
        }
        
        delegate?.chatFeed(self, didSelect: content)
    }
    
    func messageCellDidLongPressContent(messageCell: ChatFeedMessageCell) {
        guard let content = messageCell.chatFeedContent else {
            return
        }
        
        delegate?.chatFeed(self, didLongPress: content)
    }

    func messageCellDidToggleLikeContent(messageCell: ChatFeedMessageCell, completion: (() -> Void)) {
        guard let content = messageCell.chatFeedContent else {
            return
        }

        delegate?.chatFeed(self, didToggleLikeFor: content, completion: completion)
    }

    func messageCellDidSelectFailureButton(messageCell: ChatFeedMessageCell) {
        guard let content = messageCell.chatFeedContent else {
            return
        }
        
        delegate?.chatFeed(self, didSelectFailureButtonFor: content)
    }
    
    func messageCellDidSelectReplyButton(messageCell: ChatFeedMessageCell) {
        guard let content = messageCell.chatFeedContent else {
            return
        }
        
        delegate?.chatFeed(self, didSelectReplyButtonFor: content)
    }
    
    func messageCell(messageCell: ChatFeedMessageCell, didSelectLinkURL url: NSURL) {
        Router(originViewController: self, dependencyManager: dependencyManager).navigate(
            to: DeeplinkDestination(url: url),
            from: nil
        )
    }
    
    // MARK: - UIScrollViewDelegate
    
    var unstashingViaScrollingIsEnabled = true
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
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
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        delegate?.chatFeed(self, willBeginDragging: scrollView)
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.chatFeed(self, willEndDragging: scrollView, withVelocity: velocity)
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
        return colorForKey("color.message.text")
    }
}
