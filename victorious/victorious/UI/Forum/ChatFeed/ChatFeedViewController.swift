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
        }
    }
    
    // MARK: - Managing the activity indicator
    
    /// Whether or not the activity indicator above the chat messages is enabled.
    private var activityIndicatorEnabled = false {
        didSet {
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    // MARK: - ForumEventReceiver
    
    var childEventReceivers: [ForumEventReceiver] {
        return [dataSource]
    }
    
    func receive(event: ForumEvent) {
        switch event {
            case .setChatActivityIndicatorEnabled(let enabled): activityIndicatorEnabled = enabled
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
        
        collectionView.registerNib(
            VFooterActivityIndicatorView.nibForSupplementaryView(),
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: VFooterActivityIndicatorView.reuseIdentifier()
        )
        
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
        if let activityView = view as? VFooterActivityIndicatorView {
            activityView.activityIndicator.color = dependencyManager.activityIndicatorColor
            activityView.setActivityIndicatorVisible(activityIndicatorEnabled, animated: false)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard activityIndicatorEnabled else {
            return CGSize.zero
        }
        
        var size = VFooterActivityIndicatorView.desiredSizeWithCollectionViewBounds(collectionView.bounds)
        
        if collectionView.numberOfItemsInSection(0) == 0 {
            // If the collection view is empty, we want to center the activity indicator vertically, so we size it to
            // the collection view's height.
            size.height = collectionView.bounds.height - collectionView.contentInset.vertical
        }
        
        return size
    }
    
    // MARK: - ChatFeedDataSourceDelegate
    
    func chatFeedDataSource(dataSource: ChatFeedDataSource, didLoadItems newItems: [ChatFeedContent], loadingType: PaginatedLoadingType) {
        let removedPendingContentIndices = removePendingContent(newItems, loadingType: loadingType)
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
        
        let removedPendingContentIndices = removePendingContent(unstashedItems, loadingType: .newer)
        
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
    
    private func removePendingContent(contentToRemove: [ChatFeedContent], loadingType: PaginatedLoadingType) -> [Int] {
        guard let publisher = delegate?.publisher(for: self) where loadingType == .newer else {
            return []
        }
        
        if publisher.pendingItems.isEmpty || contentToRemove.isEmpty {
            return []
        }
        
        return publisher.remove(contentToRemove)
    }
    
    // MARK: - ChatFeedMessageCellDelegate
    
    func messageCellDidSelectAvatarImage(messageCell: ChatFeedMessageCell) {
        guard let userID = messageCell.chatFeedContent?.content.author.id else {
            return
        }
        
        delegate?.chatFeed(self, didSelectUserWithUserID: userID)
    }
    
    func messageCellDidSelectMedia(messageCell: ChatFeedMessageCell) {
        guard let content = messageCell.chatFeedContent else {
            return
        }
        
        delegate?.chatFeed(self, didSelectContent: content)
    }
    
    func messageCellDidSelectFailureButton(messageCell: ChatFeedMessageCell) {
        guard let content = messageCell.chatFeedContent else {
            return
        }
        
        delegate?.chatFeed(self, didSelectFailureButtonForContent: content)
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

private extension VDependencyManager {
    var activityIndicatorColor: UIColor? {
        return colorForKey("color.text")
    }
}
