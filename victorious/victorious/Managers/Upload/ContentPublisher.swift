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
    private(set) var pendingContent = [ChatFeedContent]()
    
    /// Queues `content` for publishing.
    func publish(content: ContentModel, withWidth width: CGFloat) {
        guard let chatFeedContent = ChatFeedContent(content: content, width: width, dependencyManager: dependencyManager, creationState: .waiting) else {
            assertionFailure("Failed to calculate height for chat feed content")
            return
        }
        
        pendingContent.append(chatFeedContent)
        delegate?.contentPublisher(self, didQueueContent: chatFeedContent)
        
        // We want to make sure that we send items sequentially
        guard !pendingContent.contains({ $0.creationState == .sending }) else {
            return
        }
        
        publishNextContent()
    }
    
    /// Should be called after calling `publish` to confirm that content was published, which will remove it from the
    /// queue.
    func confirmPublish(count count: Int) {
        pendingContent.removeRange(0 ..< count)
    }
    
    private func publishNextContent() {
        guard let index = indexOfContent(withState: .waiting) else {
            return
        }
        
        pendingContent[index].creationState = .sending

        upload(pendingContent[index].content) { [weak self] error in
            guard let strongSelf = self else {
                return
            }
            
            if error != nil {
                for index in strongSelf.pendingContent.indices {
                    strongSelf.pendingContent[index].creationState = .failed
                }
                // FUTURE: Update collectionView
            }
            else if let updatedIndex = strongSelf.indexOfContent(withState: .sending) {
                // The content's index will have changed by now if a preceding item was confirmed while this one was
                // being sent, so we need to get an updated index.
                strongSelf.pendingContent[updatedIndex].creationState = .sent
                strongSelf.publishNextContent()
            }
        }
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
    
    // MARK: - Handling Errors
    
    /// Retry publishing `content` that failed to be sent
    func retryPublish(chatFeedContent: ChatFeedContent) {
        guard chatFeedContent.creationState == .failed else {
            return
        }
        
        upload(chatFeedContent.content) { [weak self] error in
            guard let index = self?.index(of: chatFeedContent) else {
                return
            }
            
            if error != nil {
                self?.pendingContent[index].creationState = .failed
            }
            else {
                self?.pendingContent[index].creationState = .sent
            }
        }
    }
    
    /// Removes `content` from the pending queue
    func remove(chatFeedContent: ChatFeedContent) {
        pendingContent = pendingContent.filter { $0.content.id != chatFeedContent.content.id }
        // FUTURE: Update collectionView
    }
    
    // MARK: - Index of Queue
    
    /// Returns the first content in the queue that has the given `state`.
    private func indexOfContent(withState state: ContentCreationState) -> Int? {
        for (index, chatFeedContent) in pendingContent.enumerate() where chatFeedContent.creationState == state {
            return index
        }
        return nil
    }
    
    /// Returns the index of the specified content
    private func index(of chatFeedContent: ChatFeedContent) -> Int? {
        return pendingContent.indexOf { $0.content.id == chatFeedContent.content.id }
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
