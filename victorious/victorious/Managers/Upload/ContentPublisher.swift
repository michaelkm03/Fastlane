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
    func contentPublisher(contentPublisher: ContentPublisher, didQueueContent content: ChatFeedContent)
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
    
    weak var delegate: ContentPublisherDelegate?
    
    // MARK: - Publishing
    
    /// The content that is currently pending creation.
    // TODO: private(set)
    var pendingContent = [ChatFeedContent]()
    
    /// Queues `content` for publishing.
    func publish(content: ContentModel, withWidth width: CGFloat) {
        guard let chatFeedContent = ChatFeedContent(content: content, width: width, dependencyManager: dependencyManager, creationState: .waiting) else {
            assertionFailure("Failed to calculate height for chat feed content")
            return
        }
        
        pendingContent.append(chatFeedContent)
        delegate?.contentPublisher(self, didQueueContent: chatFeedContent)
        
        if !pendingContent.contains({ $0.creationState == .sending }) {
            publishNextContent()
        }
    }
    
    private func publishNextContent() {
        guard let index = indexOfNextContent else {
            return
        }
        
        pendingContent[index].creationState = .sending

        upload(pendingContent[index].content) { [weak self] error in
            if error != nil {
                // FUTURE: Handle failure.
            }
            else {
                self?.pendingContent[index].creationState = .sent
                self?.publishNextContent()
            }
        }
    }
    
    /// Returns the next content in the queue that's waiting to be sent and sets its `creationState` to `sending`.
    private var indexOfNextContent: Int? {
        for (index, chatFeedContent) in pendingContent.enumerate() where chatFeedContent.creationState == .waiting {
            return index
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
    
    private func remove(chatFeedContent: ChatFeedContent) {
        let index = pendingContent.indexOf { chatFeedContent.content.id == $0.content.id }
        if let index = index {
            pendingContent.removeAtIndex(index)
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
