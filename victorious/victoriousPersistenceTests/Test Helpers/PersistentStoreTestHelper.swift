//
//  PersistentStoreTestHelper.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/2/16.
//  Copyright © 2016 Victorious. All rights reserved.

import XCTest
@testable import victorious

/// Helper for testing a FetcherOperation or it's subclass.
struct PersistentStoreTestHelper {

    let persistentStore: PersistentStoreType

    func createUser(remoteId remoteId: Int, token: String = "token") -> VUser {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            return context.v_createObjectAndSave { user in
                user.remoteId = remoteId
                user.token = token
            }
        }
    }
    
    func createContent(remoteID: String, likedByCurrentUser: Bool? = nil) -> VContent {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let author = self.createUser(remoteId: 1)
            return context.v_createObjectAndSave { content in
                content.v_remoteID = remoteID
                content.v_author = author
                content.v_createdAt = Timestamp().value
                content.v_type = "image"
                content.v_isRemotelyLikedByCurrentUser = likedByCurrentUser
            }
        }
    }
    
    func createContentMediaAsset(remoteID: String) -> VContentMediaAsset {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let content = self.createContent("1")
            return context.v_createObjectAndSave { asset in
                asset.v_remoteID = remoteID
                asset.v_content = content
            }
        }
    }
    
    func createImageAsset(imageURL: String, type: String = "image") -> VImageAsset {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            return context.v_createObjectAndSave { asset in
                asset.imageURL = imageURL
            }
        }
    }
}
