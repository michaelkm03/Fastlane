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
        
        dataSource = TimePaginatedDataSource(apiPath: self.dependencyManager.mainFeedAPIPath) {
            ContentFeedOperation(url: $0)
        }
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(handleUpdateStreamURLNotification),
            name: RESTForumNetworkSource.updateStreamURLNotification,
            object: nil
        )
    }
    
    // MARK: - Dependency manager
    
    private let dependencyManager: VDependencyManager
    
    // MARK: - Data source
    
    let dataSource: TimePaginatedDataSource<ContentModel, ContentFeedOperation>
    
    private var filteredStreamAPIPath: APIPath? {
        didSet {
            let newAPIPath = filteredStreamAPIPath ?? dependencyManager.mainFeedAPIPath
            
            guard newAPIPath != dataSource.apiPath else {
                return
            }
            
            broadcast(.filterContent(path: filteredStreamAPIPath))
            
            dataSource.apiPath = newAPIPath
            
            dataSource.loadItems(.refresh) { [weak self] contents, _ in
                guard let strongSelf = self else {
                    return
                }
                
                let contents = strongSelf.processContents(contents)
                strongSelf.broadcast(.replaceContent(contents))
            }
        }
    }
    
    // MARK: - Polling
    
    private static let pollingInterval = NSTimeInterval(10.0)
    
    private var pollingTimer: VTimerManager?
    
    private func startPolling() {
        pollingTimer?.invalidate()
        
        pollingTimer = VTimerManager.scheduledTimerManagerWithTimeInterval(
            RESTForumNetworkSource.pollingInterval,
            target: self,
            selector: #selector(pollForNewContent),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc private func pollForNewContent() {
        dataSource.loadItems(.newer) { [weak self] contents, _ in
            guard let contents = self?.processContents(contents) else {
                return
            }
            
            self?.broadcast(.appendContent(contents))
        }
    }
    
    // MARK: - Processing content
    
    private func processContents(contents: [ContentModel]) -> [Content] {
        return contents.reverse().map { $0.toSDKContent() }
    }
    
    // MARK: - Notifications
    
    /// A notification that can be posted to update the API path used to fetch content in the stream.
    ///
    /// This notification's `userInfo` should contain a `streamAPIPath` key set to a `ReferenceWrapper<APIPath>`
    /// containing the desired stream API path to update to, or nil to revert back to an unfiltered feed.
    ///
    static let updateStreamURLNotification = "com.getvictorious.update-stream-url"
    
    private dynamic func handleUpdateStreamURLNotification(notification: NSNotification) {
        filteredStreamAPIPath = (notification.userInfo?["streamAPIPath"] as? ReferenceWrapper<APIPath>)?.value
    }
    
    // MARK: - ForumNetworkSource
    
    func setUp() {
        isSetUp = true
        
        dataSource.loadItems(.refresh) { [weak self] contents, error in
            guard let strongSelf = self else {
                return
            }
            
            let contents = strongSelf.processContents(contents)
            strongSelf.broadcast(.appendContent(contents))
        }
        
        startPolling()
    }
    
    func tearDown() {
        // Nothing to tear down.
    }
    
    func addChildReceiver(receiver: ForumEventReceiver) {
        if !childEventReceivers.contains({ $0 === receiver }) {
            childEventReceivers.append(receiver)
        }
    }
    
    func removeChildReceiver(receiver: ForumEventReceiver) {
        if let index = childEventReceivers.indexOf({ $0 === receiver }) {
            childEventReceivers.removeAtIndex(index)
        }
    }
    
    private(set) var isSetUp = false
    
    // MARK: - ForumEventSender
    
    private(set) weak var nextSender: ForumEventSender?
    
    func send(event: ForumEvent) {
        nextSender?.send(event)
        
        switch event {
        case .loadOldContent:
            dataSource.loadItems(.older) { [weak self] contents, error in
                guard let strongSelf = self else {
                    return
                }
                
                let contents = strongSelf.processContents(contents)
                strongSelf.broadcast(.prependContent(contents))
            }
        default:
            break
        }
    }
    
    // MARK: - ForumEventReceiver
    
    private(set) var childEventReceivers = [ForumEventReceiver]()
    
    func receive(event: ForumEvent) {
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
