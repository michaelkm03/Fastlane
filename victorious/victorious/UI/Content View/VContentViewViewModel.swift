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
            let operation = PollResultSummaryBySequenceOperation(sequenceID: self.sequence.remoteId)
            operation.queue { _ in
                self.pollResults = operation.results
                self.delegate?.didUpdatePoll()
            }
        }

        SequenceFetchOperation( sequenceID: self.sequence.remoteId, streamID: self.streamId).queue() { results, error, cancelled in
            // Update the vote/EBs thrown counts
            self.experienceEnhancerController.updateData()
            self.delegate?.didUpdateSequence()
        }

        self.commentsDataSource.loadComments(.First)
        
        if let currentUserID = VCurrentUser.user()?.remoteId.integerValue {
            SequenceUserInterationsOperation(sequenceID: self.sequence.remoteId, userID: currentUserID ).queue() { results, error, cancelled in
                self.hasReposted = self.sequence.hasBeenRepostedByMainUser.boolValue
            }
            
            FollowCountOperation(userID: Int(currentUserID)).queue() { results, error, cancelled in
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
    
    func addComment( text text: String, publishParameters: VPublishParameters?, currentTime: NSNumber? ) {
        guard let sequence = self.sequence else {
            return
        }
        
        let realtimeAttachment: Comment.RealtimeAttachment?
        if let time = currentTime?.doubleValue where time > 0.0 {
            realtimeAttachment = Comment.RealtimeAttachment( time: time )
        } else {
            realtimeAttachment = nil
        }
        
        let mediaAttachment: MediaAttachment?
        if let publishParameters = publishParameters {
            mediaAttachment = MediaAttachment(publishParameters: publishParameters)
        } else {
            mediaAttachment = nil
        }
        
        let creationParameters = Comment.CreationParameters(
            text: text,
            sequenceID: sequence.remoteId,
            replyToCommentID: nil,
            mediaAttachment: mediaAttachment,
            realtimeAttachment: realtimeAttachment
        )
        
        CommentCreateOperation(creationParameters: creationParameters).queue()
    }
    
    func answerPoll( pollAnswer: VPollAnswer, completion:((NSError?)->())? ) {
        if let answer: VAnswer = self.sequence.answerModelForPollAnswer( pollAnswer ) {
            let operation = PollVoteOperation(sequenceID: self.sequence.remoteId, answerID: answer.remoteId.integerValue)
            operation.queue() { results, error, cancelled in
                completion?(error)
                let params = [ VTrackingKeyIndex : pollAnswer == .B ? 1 : 0 ]
                VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectPollAnswer, parameters: params)
            }
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
