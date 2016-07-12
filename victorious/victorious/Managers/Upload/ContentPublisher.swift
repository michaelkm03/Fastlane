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
        // TODO: Implement me!
    }
    
    /// Transforms the chatMessage into a data type that can be persisted by the backend
    /// and uploads it.
    ///
    /// - Parameter content: The content that should be persisted.
    /// - Parameter networkResourcesDependency: A dependency manager that, optionally, contains a unique media and/or text creation URL.
    /// - Parameter completion: The block to call after upload has completed or failed. Always called.
    ///
    private func createPersistentContent(content: ContentModel, networkResourcesDependency: VDependencyManager?, completion: (NSError?) -> Void) {
        if !content.assets.isEmpty {
            guard let publishParameters = VPublishParameters(content: content) else {
                completion(PersistentContentCreatorError(code: .invalidChatMessage))
                return
            }
            
            guard
                let mediaCreationString = dependencyManager.mediaCreationURL,
                let creationURL = NSURL(string: mediaCreationString)
            else {
                completion(PersistentContentCreatorError(code: .invalidNetworkResources))
                return
            }
            
            CreateMediaUploadOperation(publishParameters: publishParameters, uploadManager: VUploadManager.sharedManager(), mediaCreationURL: creationURL, uploadCompletion: completion).queue()
        }
        else if let text = content.text {
            guard
                let textCreationString = dependencyManager.textCreationURL,
                let creationURL = NSURL(string: textCreationString)
            else {
                completion(PersistentContentCreatorError(code: .invalidNetworkResources))
                return
            }
            
            ChatMessageCreateRemoteOperation(textCreationURL: creationURL, text: text).queue { _, error, _ in
                completion(error)
            }
        }
        else {
            completion(PersistentContentCreatorError(code: .invalidChatMessage))
        }
    }
}

private extension VDependencyManager {
    var mediaCreationURL: String? {
        return stringForKey("mediaCreationURL")
    }
    
    var textCreationURL: String? {
        return stringForKey("textCreationURL")
    }
}
