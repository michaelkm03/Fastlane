//
//  PersistentContentCreator.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Describes a type that can transform a epemeral data type, such
/// as ChatMessage, into a piece of media and upload it so that it
/// persist even after the ephemeral piece it was created from is destroyed.
public protocol PersistentContentCreator {
    
    func createPersistentContent(chatMessage: ChatMessage, networkResourcesDependency: VDependencyManager?, completion: (NSError?) -> Void)
}

extension PersistentContentCreator {
    
    /// Transforms the chatMessage into a data type that can be persisted by the backend
    /// and uploads it.
    ///
    /// - Parameter chatMessage: The message that should be persisted. Must contain a media attachment.
    /// - Parameter networkResourcesDependency: A dependency manager that, optionally, contains a unique media creation URL.
    /// - Parameter completion: The block to call after upload has completed or failed. Always called.
    ///
    func createPersistentContent(chatMessage: ChatMessage, networkResourcesDependency: VDependencyManager?, completion: (NSError?) -> Void) {
        
        guard let publishParamters = VPublishParameters(chatMessage: chatMessage) else {
            let invalidChatMessageError = NSError(domain: "PersistentContentCreation", code: -1, userInfo: nil)
            completion(invalidChatMessageError)
            return
        }
    
        var creationURL: NSURL?
        if let mediaCreationString = networkResourcesDependency?.mediaCreationURL {
            creationURL = NSURL(string: mediaCreationString)
        }
        
        CreateMediaUploadOperation(publishParameters: publishParamters, uploadManager: VUploadManager.sharedManager(), mediaCreationURL: creationURL, uploadCompletion: completion).queue()
    }
}

private extension VDependencyManager {

    var mediaCreationURL: String? {
        return stringForKey("mediaCreationURL")
    }
}
