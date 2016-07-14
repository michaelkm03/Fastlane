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
    
    // MARK: - Publishing
    
    /// The content that is currently pending creation.
    private(set) var pendingContent = [ChatFeedContent]()
    
    /// Queues `content` for publishing.
    func publish(content: ContentModel) {
        pendingContent.append(ChatFeedContent(content, creationState: .waiting))
        
        // We want to make sure that we send items sequentially
        guard !pendingContent.contains({$0.creationState == .sending}) else {
            return
        }
        
        publishNextContent()
    }
    
    /// Retry publishing `content` that failed to be sent
    func retryPublish(chatFeedContent: ChatFeedContent) {
        guard chatFeedContent.creationState == .failed else {
            return
        }
        
        upload(chatFeedContent.content) { [weak self] error in
            if error != nil {
                chatFeedContent.creationState = .failed
            }
            else {
                chatFeedContent.creationState = .sent
                // FUTURE: Remove after the message comes in from content feed fetch response.
                self?.remove(chatFeedContent)
            }
        }
    }
    
    /// Removes `content` from the pending queue
    func remove(chatFeedContent: ChatFeedContent) {
        pendingContent = pendingContent.filter { $0.content.id != chatFeedContent.content.id }
        // FUTURE: Update collectionView
    }
    
    private func publishNextContent() {
        guard let chatFeedContent = getNextContent() else {
            return
        }
        
        upload(chatFeedContent.content) { [weak self] error in
            if error != nil {
                self?.pendingContent.forEach { $0.creationState = .failed }
                // FUTURE: Update collectionView
            }
            else {
                chatFeedContent.creationState = .sent
                // FUTURE: Remove after the message comes in from content feed fetch response.
                self?.remove(chatFeedContent)
                self?.publishNextContent()
            }
        }
    }
    
    /// Returns the next content in the queue that's waiting to be sent and sets its `creationState` to `sending`.
    private func getNextContent() -> ChatFeedContent? {
        for chatFeedContent in pendingContent where chatFeedContent.creationState == .waiting {
            chatFeedContent.creationState = .sending
            return chatFeedContent
        }
        
        return nil
    }
    
    /// Uploads `content` to the server.
    ///
    /// - Parameter content: The content that should be uploaded.
    /// - Parameter completion: The block to call after upload has completed or failed. Always called.
    ///
    private func upload(content: ContentModel, completion: (ErrorType?) -> Void) {
        if !content.assets.isEmpty {
            guard let publishParameters = VPublishParameters(content: content) else {
                completion(ContentPublisherError.invalidContent)
                return
            }
            
            guard
                let mediaCreationString = dependencyManager.mediaCreationURL,
                let creationURL = NSURL(string: mediaCreationString)
            else {
                completion(ContentPublisherError.invalidNetworkResources)
                return
            }
            
            CreateMediaUploadOperation(publishParameters: publishParameters, uploadManager: VUploadManager.sharedManager(), mediaCreationURL: creationURL, uploadCompletion: completion).queue()
        }
        else if let text = content.text {
            guard
                let textCreationString = dependencyManager.textCreationURL,
                let creationURL = NSURL(string: textCreationString)
            else {
                completion(ContentPublisherError.invalidNetworkResources)
                return
            }
            
            ChatMessageCreateRemoteOperation(textCreationURL: creationURL, text: text).queue { _, error, _ in
                completion(error)
            }
        }
        else {
            completion(ContentPublisherError.invalidContent)
        }
    }
}

/// Errors that can be generated by `ContentPublisher`.
enum ContentPublisherError: ErrorType {
    case invalidContent
    case invalidNetworkResources
}

private extension VDependencyManager {
    var mediaCreationURL: String? {
        return stringForKey("mediaCreationURL")
    }
    
    var textCreationURL: String? {
        return stringForKey("textCreationURL")
    }
}
