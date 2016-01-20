//
//  VContentViewViewModel+Networking.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VContentViewViewModel {
    
    func loadNetworkData() {
        
        if self.sequence.isPoll() {
            PollResultSummaryBySequenceOperation(sequenceID: self.sequence.remoteId).queue() { error in
                self.delegate?.didUpdatePoll()
            }
        }
        
        // TODO: Check if `self.deepLinkCommentId` is defined and if so,
        // implement deep link to comment using endpoint /api/comment/find/{comment_id}.
        
        SequenceFetchOperation( sequenceID: self.sequence.remoteId ).queue() { error in
            // Update the vote/EBs thrown counts
            self.experienceEnhancerController.updateData()
            
            // Sets up the monetization chain
            if (self.sequence.adBreaks?.count ?? 0) > 0 {
                self.setupAdChain()
            }
            self.delegate?.didUpdateSequence()
        }
        
        self.loadComments(.First)
        
        if let currentUserID = VCurrentUser.user()?.remoteId.integerValue {
            SequenceUserInterationsOperation(sequenceID: self.sequence.remoteId, userID: currentUserID ).queue() { error in
                self.hasReposted = self.sequence.hasBeenRepostedByMainUser.boolValue
            }
            
            FollowCountOperation(userID: Int(currentUserID)).queue() { error in
                let followerCount = self.user.numberOfFollowers?.integerValue ?? 0
                if followerCount > 0 {
                    let countString = self.largeNumberFormatter.stringForInteger(followerCount)
                    let labelFormat = NSLocalizedString("followersCount", comment:"")
                    self.followersText = NSString(format: labelFormat, countString) as String
                } else {
                    self.followersText = ""
                }
            }
        }
    }
    
    func addComment( text text: String, publishParameters: VPublishParameters, currentTime: NSNumber? ) {
        let realtimeComment: CommentParameters.RealtimeComment?
        if let time = currentTime?.doubleValue where time > 0.0,
            let assetID = (self.sequence.firstNode().assets.firstObject as? VAsset)?.remoteId?.integerValue {
                realtimeComment = CommentParameters.RealtimeComment( time: time, assetID: assetID )
        } else {
            realtimeComment = nil
        }
        
        let commentParameters = CommentParameters(
            sequenceID: self.sequence.remoteId,
            text: text,
            replyToCommentID: nil,
            mediaURL: publishParameters.mediaToUploadURL,
            mediaType: publishParameters.commentMediaAttachmentType,
            realtimeComment: realtimeComment
        )
        
        if let operation = CommentAddOperation(commentParameters: commentParameters, publishParameters: publishParameters) {
            operation.queue()
        }
    }
    
    func answerPoll( pollAnswer: VPollAnswer, completion:((NSError?)->())? ) {
        if let answer: VAnswer = self.sequence.answerModelForPollAnswer( pollAnswer ) {
            let operation = PollVoteOperation(sequenceID: self.sequence.remoteId, answerID: answer.remoteId.integerValue)
            operation.queue() { error in
                let params = [ VTrackingKeyIndex : pollAnswer == .B ? 1 : 0 ]
                VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectPollAnswer, parameters: params)
            }
        }
    }
    
    // MARK: - CommentsDataSource
    
    func loadComments( pageType: VPageType, completion:(NSError?->())? = nil ) {
        self.commentsDataSource.loadPage( pageType,
            createOperation: {
                return SequenceCommentsOperation(sequenceID: self.sequence.remoteId)
            },
            completion: { (operation, error) in
                completion?(error)
            }
        )
    }
    
    func loadComments( atPageForCommentID commentID: NSNumber, completion:((Int?, NSError?)->())?) {
        let operation = CommentFindOperation(sequenceID: self.sequence.remoteId, commentID: commentID.integerValue )
        operation.queue() { error in
            if error == nil, let pageNumber = operation.pageNumber {
                completion?(pageNumber, nil)
            } else {
                completion?(nil, error)
            }
        }
    }
    
    func flagSequence( completion completion: ((NSError?)->())? = nil ) {
        FlagSequenceOperation(sequenceID: self.sequence.remoteId).queue() { error in
            completion?( error )
        }
    }
    
    func deleteSequence( completion completion: ((NSError?)->())? = nil ) {
        DeleteSequenceOperation(sequenceID: self.sequence.remoteId).queue() { error in
            completion?( error )
        }
    }
}

private extension VSequence {
    
    func answerModelForPollAnswer( answer: VPollAnswer ) -> VAnswer? {
        switch answer {
        case .A:
            return self.firstNode()?.firstAnswers()?.first as? VAnswer
        case .B:
            return self.firstNode()?.firstAnswers()?.last as? VAnswer
        default:
            return nil
        }
    }
}
