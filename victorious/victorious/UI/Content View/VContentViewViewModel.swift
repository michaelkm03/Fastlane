//
//  VContentViewViewModel+Networking.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

public extension VContentViewViewModel {
    
    func loadNetworkData() {
        
        let sequenceID = Int64(self.sequence.remoteId)!
        
        if self.sequence.isPoll() {
            PollResultSummaryBySequenceOperation(sequenceID: sequenceID).queue() { error in
                self.delegate?.didUpdatePollsData()
            }
        }
        
        if let deepLinkCommentId = self.deepLinkCommentId {
            self.findComment( commendID: deepLinkCommentId,
                completion: { (pageNumber, error) in
                    guard let pageNumber = pageNumber else {
                        return
                    }
                    
                    self.delegate?.didUpdateCommentsWithDeepLink( deepLinkCommentId )
                    let sequenceID = Int64(self.sequence.remoteId)!
                    let operation = SequenceCommentsOperation(sequenceID: sequenceID, pageNumber: pageNumber)
                    self.loadCommentsOperation = operation
                })
        } else {
            SequenceFetchOperation( sequenceID: sequenceID ).queue() { error in
                // This is here to update the vote counts
                self.experienceEnhancerController.updateData()
                
                // Sets up the monetization chain
                if (self.sequence.adBreaks?.count ?? 0) > 0 {
                    self.setupAdChain()
                }
                if self.endCardViewModel == nil {
                    self.updateEndcard()
                }
                self.delegate?.didUpdateContent()
            }
            self.loadComments(.First)
        }
        
        if let currentUserID = VUser.currentUser()?.remoteId.integerValue {
            SequenceUserInterationsOperation(sequenceID: sequenceID, userID: Int64(currentUserID) ).queue() { error in
                self.hasReposted = self.sequence.hasBeenRepostedByMainUser.boolValue
            }
            
            FollowCountOperation(userID: Int64(currentUserID)).queue() { error in
                let followerCount = self.user.numberOfFollowers?.integerValue ?? 0
                if followerCount > 0 {
                    let countString = self.largeNumberFormatter.stringForInteger(followerCount)
                    let labelString = NSLocalizedString("followers", comment:"")
                    self.followersText = "\(countString) \(labelString)"
                } else {
                    self.followersText = ""
                }
            }
        }
    }
    
    func loadComments( pageType: VPageType ) {
        
        let sequenceID = Int64(self.sequence.remoteId)!
        
        let operation: SequenceCommentsOperation?
        switch pageType {
        case .First:
            operation =  SequenceCommentsOperation(sequenceID: sequenceID)
        case .Next:
            operation = self.loadCommentsOperation?.next()
        case .Previous:
            operation = self.loadCommentsOperation?.prev()
        }
        
        if let currentOperation = operation {
            currentOperation.queue()
            self.loadCommentsOperation = currentOperation
        }
    }
    
    func loadNextSequence( success success:(VSequence?)->(), failure:(NSError?)->() ) {
        guard let nextSequenceId = self.endCardViewModel.nextSequenceId,
            let nextSeuqneceIntegerId = Int64(nextSequenceId) else {
                failure(nil)
                return
        }
        
        let sequenceFetchOperation = SequenceFetchOperation( sequenceID: nextSeuqneceIntegerId )
        sequenceFetchOperation.queue() { error in
            
            if let sequence: VSequence? = MainPersistentStore().sync({ context in
                return context.findObjects( [ "remoteId" : nextSequenceId ] ).first
            }) where error == nil {
                success( sequence )
            } else {
                failure(error)
            }
        }
    }
    
    func findComment( commendID commentID: NSNumber, completion:(Int?, NSError?)->() ) {
        let operation = CommentFindOperation(sequenceID: Int64(self.sequence.remoteId)!, commentID: commentID.longLongValue )
        operation.queue() { error in
            if error == nil, let pageNumber = operation.pageNumber {
                completion(pageNumber, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func addComment( text text: String, publishParameters: VPublishParameters, currentTime: NSNumber? ) {
        
        let realtimeComment: CommentParameters.RealtimeComment?
        if let time = currentTime?.doubleValue where time > 0.0,
            let assetID = (self.sequence.firstNode().assets.firstObject as? VAsset)?.remoteId?.longLongValue {
                realtimeComment = CommentParameters.RealtimeComment( time: time, assetID: assetID )
        } else {
            realtimeComment = nil
        }
        
        let commentParameters = CommentParameters(
            sequenceID: Int64(sequence.remoteId)!,
            text: text,
            mediaURL: publishParameters.mediaToUploadURL,
            mediaType: publishParameters.commentMediaAttachmentType,
            realtimeComment: realtimeComment
        )
        
        let operation = CommentAddOperation(commentParameters: commentParameters, publishParameters: publishParameters)
        operation.queue()
        
        VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidPostComment,
            parameters: [
                VTrackingKeyTextLength : text.characters.count,
                VTrackingKeyMediaType : publishParameters.mediaToUploadURL?.pathExtension ?? ""
            ]
        )
    }
    
    func answerPoll( answer: VPollAnswer, completion:((NSError?)->())? ) {
        // TODO: api/pollresult/create"
        
        // TODO: on complete
        let params = [ VTrackingKeyIndex : answer == .B ? 1 : 0 ]
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectPollAnswer, parameters: params)
    }
}

private extension VPublishParameters {
    var commentMediaAttachmentType: MediaAttachmentType {
        if self.isGIF {
            return .GIF
        } else if self.isVideo {
            return .Video
        }
        return .Image
    }
}
