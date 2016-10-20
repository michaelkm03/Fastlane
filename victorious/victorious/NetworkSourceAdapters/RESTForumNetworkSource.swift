//
//  RESTForumNetworkSource.swift
//  victorious
//
//  Created by Jarod Long on 5/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK

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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUpdateStreamURLNotification),
            name: NSNotification.Name(rawValue: RESTForumNetworkSource.updateStreamURLNotification),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            forName: .loggedInChanged,
            object: nil,
            queue: nil) { [weak self] _ in
                if VCurrentUser.user == nil {
                    self?.tearDown()
                }
        }
    }
    
    // MARK: - Dependency manager
    
    private let dependencyManager: VDependencyManager
    
    // MARK: - Data source
    
    let dataSource: TimePaginatedDataSource<Content, ContentFeedOperation>
    
    private var filteredStreamAPIPath: APIPath? {
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
    
    private static let pollingInterval = TimeInterval(5.0)
    
    private var pollingTimer: VTimerManager?
    
    private func startPolling() {
        pollingTimer?.invalidate()
        
        pollingTimer = VTimerManager.scheduledTimerManager(
            withTimeInterval: RESTForumNetworkSource.pollingInterval,
            target: self,
            selector: #selector(pollForNewContent),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc private func pollForNewContent() {
        loadContent(.newer)
    }
    
    // MARK: - Loading content
    
    /// Loads a page of content with the given `loadingType`.
    private func loadContent(_ loadingType: PaginatedLoadingType) {
        let itemsWereLoaded = dataSource.loadItems(loadingType) { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
                case .success(let feedResult):
                    strongSelf.broadcast(.handleContent(feedResult.contents.reversed(), loadingType))
                    
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
    /// This notification's `userInfo` should contain a `selectedItem` key set to a `ListMenuSelectedItem` object
    /// that containing the desired stream API path to update to, or nil to revert back to an unfiltered feed.
    ///
    static let updateStreamURLNotification = "com.getvictorious.update-stream-url"
    
    private dynamic func handleUpdateStreamURLNotification(_ notification: NSNotification) {
        filteredStreamAPIPath = (notification.userInfo?["selectedItem"] as? ListMenuSelectedItem)?.streamAPIPath
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
        pollingTimer?.invalidate()
    }
    
    func addChildReceiver(_ receiver: ForumEventReceiver) {
        if !childEventReceivers.contains(where: { $0 === receiver }) {
            childEventReceivers.append(receiver)
        }
    }
    
    func removeChildReceiver(_ receiver: ForumEventReceiver) {
        if let index = childEventReceivers.index(where: { $0 === receiver }) {
            childEventReceivers.remove(at: index)
        }
    }
    
    private(set) var isSetUp = false
    
    // MARK: - ForumEventSender
    
    private(set) weak var nextSender: ForumEventSender?
    
    func send(_ event: ForumEvent) {
        nextSender?.send(event)
        
        switch event {
            case .loadOldContent: loadContent(.older)
            default: break
        }
    }
    
    // MARK: - ForumEventReceiver
    
    private(set) var childEventReceivers = [ForumEventReceiver]()
    
    func receive(_ event: ForumEvent) {
        // Nothing yet.
    }
}

private extension VDependencyManager {
    var mainFeedAPIPath: APIPath {
        guard let apiPath = apiPath(forKey: "mainFeedURL") else {
            assertionFailure("Failed to retrieve main feed API path from dependency manager.")
            return APIPath(templatePath: "")
        }
        
        return apiPath
    }
}
