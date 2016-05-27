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
        self.dependencyManager = dependencyManager.childDependencyForKey("networkResources")!
    }
    
    // MARK: - Dependency manager
    
    private let dependencyManager: VDependencyManager
    
    // MARK: - ForumNetworkSource
    
    func setUp() {
        isSetUp = true
        
//        ContentListFetchOperation(urlString: dependencyManager.mainFeedURLString, fromTime: NSDate()).queue { [weak self] result, error, cancelled in
//            for content in result ?? [] {
//                guard let content = content as? VContent, author = content.author else {
//                    continue
//                }
//                
//                guard let chatMessage = ChatMessage(
//                    serverTime: content.releasedAt,
//                    fromUser: ChatMessageUser(id: author.remoteId.integerValue, name: author.name, profileURL: nil),
//                    text: content.text,
//                    mediaAttachment: nil
//                ) else {
//                    continue
//                }
//                
//                self?.broadcast(chatMessage)
//            }
//        }
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
    
    // MARK: - ForumEventReceiver
    
    private(set) var childEventReceivers = [ForumEventReceiver]()
    
    func receive(event: ForumEvent) {
        // Nothing yet.
    }
}

private extension VDependencyManager {
    var mainFeedURLString: String {
        return stringForKey("mainFeedUrl")
    }
}
