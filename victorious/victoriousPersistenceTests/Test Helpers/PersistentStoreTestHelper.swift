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
                content.v_isLikedByCurrentUser = likedByCurrentUser
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
    
    func createSequence(remoteId remoteId: String, category: String = kVOwnerVideoCategory) -> VSequence {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            return context.v_createObjectAndSave { sequence in
                sequence.remoteId = remoteId
                sequence.category = category
                sequence.commentCount = 1
                sequence.createdBy = 1
                sequence.hasBeenRepostedByMainUser = true
                sequence.hasReposted = true
                sequence.isComplete = true
                sequence.isLikedByMainUser = true
                sequence.isComplete = true
                sequence.isGifStyle = true
                sequence.isRemix = true
                sequence.isRepost = true
                sequence.likeCount = 1
                sequence.memeCount = 1
                sequence.nameEmbeddedInContent = true
                sequence.permissionsMask = 1
                sequence.repostCount = 1
            }
        }
    }
    
    func createNode(remoteId: Int, sequence: VSequence) -> VNode {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            return context.v_createObjectAndSave { node in
                node.remoteId = remoteId
                node.sequence = sequence
            }
        }
    }

    func createAdBreak(adSystemID adSystemID: UInt = kMonetizationPartnerIMA, adTag: String = "http://example.com") -> VAdBreak {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            return context.v_createObjectAndSave { adBreak in
                adBreak.adSystemID = adSystemID
                adBreak.adTag = adTag
            }
        }
    }

    func createConversation(remoteId remoteId: Int) -> VConversation {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let conversation: VConversation = context.v_createObject()
            conversation.displayOrder = 0
            conversation.remoteId = remoteId
            conversation.lastMessageText = ""
            conversation.isRead = false
            conversation.postedAt = NSDate()
            conversation.messages = NSOrderedSet()
            return conversation
        }
    }
    
    func createVoteResult(sequence: VSequence, count: Int = 0, remoteId: Int = 0) -> VVoteResult {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let voteResult: VVoteResult = context.v_createObject()
            voteResult.sequence = sequence
            voteResult.count = count
            voteResult.remoteId = remoteId
            return voteResult
        }
    }
}
