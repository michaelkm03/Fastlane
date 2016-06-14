//
//  PersistentContentCreator.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Describes a type that can transform a epemeral data type, such
/// as Content, into a piece of media and upload it so that it persists
/// even after the ephemeral piece it was created from is destroyed.
protocol PersistentContentCreator {
    
    func createPersistentContent(content: ContentModel, networkResourcesDependency: VDependencyManager?, completion: (NSError?) -> Void)
}

extension PersistentContentCreator {
    
    /// Transforms the chatMessage into a data type that can be persisted by the backend
    /// and uploads it.
    ///
    /// - Parameter content: The content that should be persisted.
    /// - Parameter networkResourcesDependency: A dependency manager that, optionally, contains a unique media and/or text creation URL.
    /// - Parameter completion: The block to call after upload has completed or failed. Always called.
    ///
    func createPersistentContent(content: ContentModel, networkResourcesDependency: VDependencyManager?, completion: (NSError?) -> Void) {
        if !content.assets.isEmpty {
            guard let publishParameters = VPublishParameters(content: content) else {
                completion(PersistentContentCreatorError(code: .invalidChatMessage))
                return
            }
            
            //Create media
            guard let mediaCreationString = networkResourcesDependency?.mediaCreationURL,
                let creationURL = NSURL(string: mediaCreationString) else {
                    completion(PersistentContentCreatorError(code: .invalidNetworkResources))
                    return
            }
            
            CreateMediaUploadOperation(publishParameters: publishParameters, uploadManager: VUploadManager.sharedManager(), mediaCreationURL: creationURL, uploadCompletion: completion).queue()
        } else if let text = content.text {
            
            //Create text
            guard let textCreationString = networkResourcesDependency?.textCreationURL,
                let creationURL = NSURL(string: textCreationString) else {
                    completion(PersistentContentCreatorError(code: .invalidNetworkResources))
                    return
            }
            
            ChatMessageCreateRemoteOperation(textCreationURL: creationURL, text: text).queue() { _, error, _ in
                completion(error)
            }
        } else {
            completion(PersistentContentCreatorError(code: .invalidChatMessage))
        }
    }
}

/// Describes errors that can be returned from PersistentContentCreator's
class PersistentContentCreatorError: NSError {
    
    enum Code: Int {
        case invalidChatMessage = -1
        case invalidNetworkResources = -2
    }
    
    static let errorDomain = "PersistentContentCreation"
    
    var isInvalidNetworkResourcesError: Bool {
        return code == Code.invalidNetworkResources.rawValue
    }
    
    init(code: Code) {
        super.init(domain: PersistentContentCreatorError.errorDomain, code: code.rawValue, userInfo: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
