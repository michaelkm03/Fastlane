//
//  ContentPublisher.swift
//  victorious
//
//  Created by Jarod Long on 7/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

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
    func contentPublisher(contentPublisher: ContentPublisher, didQueue content: ChatFeedContent)
    
    /// Notifies the delegate that the given `content` failed to send.
    func contentPublisher(contentPublisher: ContentPublisher, didFailToSend content: ChatFeedContent)
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
    
    private let dependencyManager: VDependencyManager
    
    // MARK: - Configuration
    
    var optimisticPostingEnabled = true
    
    weak var delegate: ContentPublisherDelegate?
    
    // MARK: - Publishing
    
    /// The content that is currently pending creation.
    private(set) var pendingItems = [ChatFeedContent]()
    
    /// Queues `content` for publishing.
    func publish(content: ContentModel, withWidth width: CGFloat) {
        if optimisticPostingEnabled {
            guard let chatFeedContent = ChatFeedContent(content: content, width: width, dependencyManager: dependencyManager, creationState: .waiting) else {
                assertionFailure("Failed to calculate height for chat feed content")
                return
            }
            
            pendingItems.append(chatFeedContent)
            delegate?.contentPublisher(self, didQueue: chatFeedContent)
            
            // We want to make sure that we send items sequentially
            guard !pendingItems.contains({ $0.creationState == .sending }) else {
                return
            }
            
            publishNextContent()
        }
        else {
            upload(content)
        }
    }
    
    /// Removes `chatFeedContents` from the `pendingQueue`, returning the indices of each removed item in the queue.
    func remove(itemsToRemove: [ChatFeedContent]) -> [Int] {
        
        let indices = pendingItems.enumerate().filter { index, item in
            itemsToRemove.contains { itemToRemove in
                 itemToRemove.matches(item)
            }
        }.map { $0.index }
        
        pendingItems = pendingItems.filter { item in
            !itemsToRemove.contains { itemToRemove in
                 itemToRemove.matches(item)
            }
        }
        
        return indices
    }
    
    private func publishNextContent() {
        guard let index = indexOfContent(withState: .waiting) else {
            return
        }
        
        pendingItems[index].creationState = .sending

        upload(pendingItems[index].content) { [weak self] error in
            // The content's index will have changed by now if a preceding item was confirmed while this one was being
            // sent, so we need to get an updated index.
            guard let strongSelf = self, updatedIndex = strongSelf.indexOfContent(withState: .sending) else {
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
    private func upload(content: ContentModel, completion: ((ErrorType?) -> Void)? = nil) {
        if !content.assets.isEmpty {
            guard let publishParameters = VPublishParameters(content: content) else {
                completion?(ContentPublisherError.invalidContent)
                return
            }
            
            guard let apiPath = dependencyManager.mediaCreationAPIPath(for: content) else {
                completion?(ContentPublisherError.invalidNetworkResources)
                return
            }
            
            CreateMediaUploadOperation(publishParameters: publishParameters, uploadManager: VUploadManager.sharedManager(), apiPath: apiPath).queue() { result in
                switch result {
                    case .success: break
                        completion?(nil)
                    case .failure(let error):
                        completion?(error)
                    case .cancelled: break
                }
            }
        }
        else if let text = content.text {
            guard let apiPath = dependencyManager.textCreationAPIPath(for: content) else {
                completion?(ContentPublisherError.invalidNetworkResources)
                return
            }
            
            ChatMessageCreateRemoteOperation(apiPath: apiPath, text: text).queue { _, error, _ in
                completion?(error)
            }
        }
        else {
            completion?(ContentPublisherError.invalidContent)
        }
    }
    
    // MARK: - Handling Errors
    
    /// Retry publishing `content` that failed to be sent
    func retryPublish(chatFeedContent: ChatFeedContent) -> Int? {
        guard let index = index(of: chatFeedContent) where chatFeedContent.creationState == .failed else {
            return nil
        }
        
        pendingItems[index].creationState = .sending
        
        upload(chatFeedContent.content) { [weak self] error in
            guard let strongSelf = self, updatedIndex = strongSelf.index(of: chatFeedContent) else {
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
    private func indexOfContent(withState state: ContentCreationState) -> Int? {
        return pendingItems.indexOf { $0.creationState == state }
    }
    
    /// Returns the index of the specified content
    private func index(of chatFeedContent: ChatFeedContent) -> Int? {
        return pendingItems.indexOf { $0.matches(chatFeedContent) }
    }
}

/// Errors that can be generated by `ContentPublisher`.
enum ContentPublisherError: ErrorType {
    case invalidContent
    case invalidNetworkResources
}

private extension VDependencyManager {
    func mediaCreationAPIPath(for content: ContentModel) -> APIPath? {
        return apiPathForKey("mediaCreationURL", macroReplacements: [
            "%%TIME_CURRENT%%": content.postedAt?.apiString ?? ""
        ])
    }
    
    func textCreationAPIPath(for content: ContentModel) -> APIPath? {
        return apiPathForKey("textCreationURL", macroReplacements: [
            "%%TIME_CURRENT%%": content.postedAt?.apiString ?? ""
        ])
    }
}

private extension ChatFeedContent {
    func matches(item: ChatFeedContent) -> Bool {
        guard self.content.wasCreatedByCurrentUser && item.content.wasCreatedByCurrentUser else {
            return false
        }
        return self.content.postedAt == item.content.postedAt
    }
}
