//
//  ContentPublisher.swift
//  victorious
//
//  Created by Jarod Long on 7/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK

/// Different states that content can be in while being created by the user.
enum ContentCreationState {
    /// The content is queued locally and waiting to be sent to the server.
    case waiting
    
    /// The content is currently being sent to the server.
    case sending
    
    /// The content was sent to the server successfully and is awaiting arrival in the feed.
    case sent
    
    /// The content, or content that preceded it in the queue, failed to be sent.
    case failed
}

/// A delegate protocol for `ContentPublisher`.
protocol ContentPublisherDelegate: class {
    /// Notifies the delegate that the given `content` was queued to be published.
    func contentPublisher(_ contentPublisher: ContentPublisher, didQueue content: ChatFeedContent)
    
    /// Notifies the delegate that the given `content` failed to send.
    func contentPublisher(_ contentPublisher: ContentPublisher, didFailToSend content: ChatFeedContent)
}

/// An object that manages the publishing of user content.
///
/// It uses a queueing system that facilitates correct content creation order, cascading failures, and optimistic
/// display of content in the feed.
///
class ContentPublisher {
    
    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
    }
    
    // MARK: - Dependency manager
    
    fileprivate let dependencyManager: VDependencyManager
    
    // MARK: - Configuration
    
    var optimisticPostingEnabled = true
    
    weak var delegate: ContentPublisherDelegate?
    
    // MARK: - Publishing
    
    /// The content that is currently pending creation.
    private var pendingItems = [ChatFeedContent]()
    
    /// Returns all of the content that is pending publishing for the given `chatRoomID`.
    func pendingItems(forChatRoomWithID chatRoomID: ChatRoom.ID?) -> [ChatFeedContent] {
        return pendingItems.filter { $0.pendingChatRoomID == chatRoomID }
    }
    
    /// Queues `content` for publishing.
    func publish(_ content: Content, withWidth width: CGFloat, toChatRoomWithID chatRoomID: ChatRoom.ID?) {
        if optimisticPostingEnabled {
            guard let chatFeedContent = ChatFeedContent(
                content: content,
                width: width,
                dependencyManager: dependencyManager,
                creationState: .waiting,
                pendingChatRoomID: chatRoomID
            ) else {
                assertionFailure("Failed to calculate height for chat feed content")
                return
            }
            
            pendingItems.append(chatFeedContent)
            delegate?.contentPublisher(self, didQueue: chatFeedContent)
            
            // We want to make sure that we send items sequentially
            guard !pendingItems.contains(where: { $0.creationState == .sending }) else {
                return
            }
            
            publishNextContent()
        }
        else {
            upload(content, toChatRoomWithID: chatRoomID)
        }
    }
    
    /// Removes `chatFeedContents` from the `pendingQueue`, returning the indices of each removed item in the queue.
    func remove(_ itemsToRemove: [ChatFeedContent]) -> [Int] {
        let indices = pendingItems.enumerated().filter { index, item in
            itemsToRemove.contains { itemToRemove in
                 itemToRemove.matches(item)
            }
        }.map { $0.offset }
        
        pendingItems = pendingItems.filter { item in
            !itemsToRemove.contains { itemToRemove in
                 itemToRemove.matches(item)
            }
        }
        
        return indices
    }
    
    fileprivate func publishNextContent() {
        guard let index = indexOfContent(withState: .waiting) else {
            return
        }
        
        pendingItems[index].creationState = .sending

        upload(pendingItems[index].content, toChatRoomWithID: pendingItems[index].pendingChatRoomID) { [weak self] error in
            // The content's index will have changed by now if a preceding item was confirmed while this one was being
            // sent, so we need to get an updated index.
            guard let strongSelf = self, let updatedIndex = strongSelf.indexOfContent(withState: .sending) else {
                return
            }
            
            if error != nil {
                for index in strongSelf.pendingItems.indices {
                    strongSelf.pendingItems[index].creationState = .failed
                }
                
                strongSelf.delegate?.contentPublisher(strongSelf, didFailToSend: strongSelf.pendingItems[updatedIndex])
            }
            else {
                strongSelf.pendingItems[updatedIndex].creationState = .sent
                strongSelf.publishNextContent()
            }
        }
    }
    
    /// Uploads `content` to the server.
    ///
    /// - Parameter content: The content that should be uploaded.
    /// - Parameter completion: The block to call after upload has completed or failed. Always called.
    ///
    private func upload(_ content: Content, toChatRoomWithID chatRoomID: ChatRoom.ID?, completion: ((Error?) -> Void)? = nil) {
        if content.type == .sticker {
            guard
                let apiPath = dependencyManager.stickerCreationAPIPath(for: content, chatRoomID: chatRoomID),
                let operation = CreateStickerOperation(apiPath: apiPath, content: content)
            else {
                completion?(ContentPublisherError.invalidNetworkResources)
                return
            }
            
            operation.queue { result in
                switch result {
                    case .success, .cancelled: completion?(nil)
                    case .failure(let error): completion?(error)
                }
            }
        }
        else if !content.assets.isEmpty {
            guard let publishParameters = VPublishParameters(content: content) else {
                completion?(ContentPublisherError.invalidContent)
                return
            }
            
            guard
                let apiPath = dependencyManager.mediaCreationAPIPath(for: content, chatRoomID: chatRoomID),
                let operation = CreateMediaUploadOperation(apiPath: apiPath, publishParameters: publishParameters, uploadManager: VUploadManager.shared())
            else {
                completion?(ContentPublisherError.invalidNetworkResources)
                return
            }
            
            operation.queue { result in
                switch result {
                    case .success, .cancelled: completion?(nil)
                    case .failure(let error): completion?(error)
                }
            }
        }
        else if let text = content.text {
            guard
                let apiPath = dependencyManager.textCreationAPIPath(for: content, chatRoomID: chatRoomID),
                let request = ChatMessageCreateRequest(apiPath: apiPath, text: text)
            else {
                completion?(ContentPublisherError.invalidNetworkResources)
                return
            }
            
            RequestOperation(request: request).queue { result in
                switch result {
                    case .success, .cancelled: completion?(nil)
                    case .failure(let error): completion?(error)
                }
            }
        }
        else {
            completion?(ContentPublisherError.invalidContent)
        }
    }
    
    // MARK: - Handling Errors
    
    /// Retry publishing `content` that failed to be sent
    func retryPublish(_ chatFeedContent: ChatFeedContent) -> Int? {
        guard let index = index(of: chatFeedContent) , chatFeedContent.creationState == .failed else {
            return nil
        }
        
        pendingItems[index].creationState = .sending
        
        upload(chatFeedContent.content, toChatRoomWithID: chatFeedContent.pendingChatRoomID) { [weak self] error in
            guard let strongSelf = self, let updatedIndex = strongSelf.index(of: chatFeedContent) else {
                return
            }
            
            if error != nil {
                strongSelf.pendingItems[updatedIndex].creationState = .failed
                strongSelf.delegate?.contentPublisher(strongSelf, didFailToSend: chatFeedContent)
            }
            else {
                strongSelf.pendingItems[updatedIndex].creationState = .sent
            }
        }
        
        return index
    }
    
    // MARK: - Index of Queue
    
    /// Returns the first content in the queue that has the given `state`.
    fileprivate func indexOfContent(withState state: ContentCreationState) -> Int? {
        return pendingItems.index { $0.creationState == state }
    }
    
    /// Returns the index of the specified content
    fileprivate func index(of chatFeedContent: ChatFeedContent) -> Int? {
        return pendingItems.index { $0.matches(chatFeedContent) }
    }
}

/// Errors that can be generated by `ContentPublisher`.
enum ContentPublisherError: Error {
    case invalidContent
    case invalidNetworkResources
}

private extension VDependencyManager {
    func mediaCreationAPIPath(for content: Content, chatRoomID: ChatRoom.ID?) -> APIPath? {
        return apiPath(forKey: "mediaCreationURL", macroReplacements: [
            "%%TIME_CURRENT%%": content.postedAt?.apiString ?? "",
            "%%ROOM_ID%%": chatRoomID ?? ""
        ])
    }
    
    func stickerCreationAPIPath(for content: Content, chatRoomID: ChatRoom.ID?) -> APIPath? {
        guard let externalID = content.assets.first?.externalID else {
            return nil
        }
        
        return apiPath(forKey: "sticker.creation.URL", macroReplacements: [
            "%%TIME_CURRENT%%": content.postedAt?.apiString ?? "",
            "%%CONTENT_ID%%": externalID,
            "%%ROOM_ID%%": chatRoomID ?? ""
        ])
    }
    
    func textCreationAPIPath(for content: Content, chatRoomID: ChatRoom.ID?) -> APIPath? {
        return apiPath(forKey: "textCreationURL", macroReplacements: [
            "%%TIME_CURRENT%%": content.postedAt?.apiString ?? "",
            "%%ROOM_ID%%": chatRoomID ?? ""
        ])
    }
}

private extension ChatFeedContent {
    func matches(_ item: ChatFeedContent) -> Bool {
        guard self.content.wasCreatedByCurrentUser && item.content.wasCreatedByCurrentUser else {
            return false
        }
        return self.content.postedAt == item.content.postedAt
    }
}
