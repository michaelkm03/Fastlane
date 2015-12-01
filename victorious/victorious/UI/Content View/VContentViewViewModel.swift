//
//  VContentViewViewModel+Networking.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

extension VContentViewViewModel {
    
    func reloadData() {
        
        let sequenceID = Int64(self.sequence.remoteId)!
        
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
        
        if self.sequence.isPoll() {
            PollResultSummaryBySequenceOperation(sequenceID: sequenceID).queue() { error in
                self.delegate?.didUpdatePollsData()
            }
        }
        
        if let deepLinkCommentId = self.deepLinkCommentId {
            // TODO: /api/comments/find
            // See `loadCommentsWithCommentId:`
        } else {
            self.loadComments(.First)
        }
        
        if let currentUserID = VUser.currentUser()?.remoteId.integerValue {
            SequenceUserInterationsOperation(sequenceID: sequenceID, userID: Int64(currentUserID) ).queue() { error in
                // TODO: Change to KVO
                self.hasReposted = self.sequence.hasBeenRepostedByMainUser.boolValue
            }
            
            FollowCountOperation(userID: Int64(currentUserID)).queue() { error in
                let followerCount = self.user.numberOfFollowers?.integerValue ?? 0
                if followerCount > 0 {
                    // TODO: Change to KVO
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
            operation = SequenceCommentsOperation(sequenceID: sequenceID)
        case .Next:
            operation = (self.loadCommentsOperation as? SequenceCommentsOperation)?.nextPageOperation
        case .Previous:
            operation = (self.loadCommentsOperation as? SequenceCommentsOperation)?.previousPageOperation
        }
        
        if let currentOperation = operation {
            currentOperation.queue() { error in
                self.delegate?.didUpdateCommentsWithPageType( pageType )
            }
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
}
