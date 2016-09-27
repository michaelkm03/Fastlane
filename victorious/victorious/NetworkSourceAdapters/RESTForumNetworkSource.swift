//
//  RESTForumNetworkSource.swift
//  victorious
//
//  Created by Jarod Long on 5/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

class RESTForumNetworkSource: NSObject, ForumNetworkSource {
    
    // MARK: - Initialization
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager.networkResources ?? dependencyManager
        
        dataSource = TimePaginatedDataSource(
            apiPath: self.dependencyManager.mainFeedAPIPath,
            createOperation: { ContentFeedOperation(apiPath: $0, payloadType: .regular) },
            processOutput: { $0.contents }
        )
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(handleUpdateStreamURLNotification),
            name: RESTForumNetworkSource.updateStreamURLNotification,
            object: nil
        )
    }
    
    // MARK: - Dependency manager
    
    fileprivate let dependencyManager: VDependencyManager
    
    // MARK: - Data source
    
    let dataSource: TimePaginatedDataSource<Content, ContentFeedOperation>
    
    fileprivate var filteredStreamAPIPath: APIPath? {
        didSet {
            let newAPIPath = filteredStreamAPIPath ?? dependencyManager.mainFeedAPIPath
            
            guard newAPIPath != dataSource.apiPath else {
                return
            }
            
            broadcast(.filterContent(path: filteredStreamAPIPath))
            
            dataSource.apiPath = newAPIPath
            
            loadContent(.refresh)
        }
    }
    
    // MARK: - Polling
    
    fileprivate static let pollingInterval = NSTimeInterval(5.0)
    
    fileprivate var pollingTimer: VTimerManager?
    
    fileprivate func startPolling() {
        pollingTimer?.invalidate()
        
        pollingTimer = VTimerManager.scheduledTimerManagerWithTimeInterval(
            RESTForumNetworkSource.pollingInterval,
            target: self,
            selector: #selector(pollForNewContent),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc fileprivate func pollForNewContent() {
        loadContent(.newer)
    }
    
    // MARK: - Loading content
    
    /// Loads a page of content with the given `loadingType`.
    fileprivate func loadContent(_ loadingType: PaginatedLoadingType) {
        let itemsWereLoaded = dataSource.loadItems(loadingType) { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
                case .success(let feedResult):
                    strongSelf.broadcast(.handleContent(feedResult.contents.reverse(), loadingType))
                    
                    if let refreshStage = feedResult.refreshStage {
                        strongSelf.broadcast(.refreshStage(refreshStage))
                    }
                    else {
                        strongSelf.broadcast(.closeStage(.main))
                    }
                    
                    strongSelf.broadcast(.setLoadingContent(false, loadingType))
                
                case .failure(_), .cancelled:
                    break
            }
        }
        
        if itemsWereLoaded {
            broadcast(.setLoadingContent(true, loadingType))
        }
    }
    
    // MARK: - Notifications
    
    /// A notification that can be posted to update the API path used to fetch content in the stream.
    ///
    /// This notification's `userInfo` should contain a `streamAPIPath` key set to a `ReferenceWrapper<APIPath>`
    /// containing the desired stream API path to update to, or nil to revert back to an unfiltered feed.
    ///
    static let updateStreamURLNotification = "com.getvictorious.update-stream-url"
    
    fileprivate dynamic func handleUpdateStreamURLNotification(_ notification: NSNotification) {
        filteredStreamAPIPath = (notification.userInfo?["selectedItem"] as? ReferenceWrapper<ListMenuSelectedItem>)?.value.streamAPIPath
    }
    
    // MARK: - ForumNetworkSource
    
    func setUp() {
        isSetUp = true
        broadcast(.setOptimisticPostingEnabled(true))
        broadcast(.setChatActivityIndicatorEnabled(true))
        loadContent(.refresh)
        startPolling()
    }
    
    func tearDown() {
        // Nothing to tear down.
    }
    
    func addChildReceiver(_ receiver: ForumEventReceiver) {
        if !childEventReceivers.contains({ $0 === receiver }) {
            childEventReceivers.append(receiver)
        }
    }
    
    func removeChildReceiver(_ receiver: ForumEventReceiver) {
        if let index = childEventReceivers.indexOf({ $0 === receiver }) {
            childEventReceivers.removeAtIndex(index)
        }
    }
    
    fileprivate(set) var isSetUp = false
    
    // MARK: - ForumEventSender
    
    fileprivate(set) weak var nextSender: ForumEventSender?
    
    func send(_ event: ForumEvent) {
        nextSender?.send(event)
        
        switch event {
            case .loadOldContent: loadContent(.older)
            default: break
        }
    }
    
    // MARK: - ForumEventReceiver
    
    fileprivate(set) var childEventReceivers = [ForumEventReceiver]()
    
    func receive(_ event: ForumEvent) {
        // Nothing yet.
    }
}

private extension VDependencyManager {
    var mainFeedAPIPath: APIPath {
        guard let apiPath = apiPathForKey("mainFeedURL") else {
            assertionFailure("Failed to retrieve main feed API path from dependency manager.")
            return APIPath(templatePath: "")
        }
        
        return apiPath
    }
}
