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
            SequencePollResultsOperation( sequenceID: sequenceID ).queue() { error in
                self.delegate?.didUpdatePollsData()
            }
        }
        
        if let deepLinkCommentId = self.deepLinkCommentId {
            // TODO: /api/comments/find
            // See `loadCommentsWithCommentId:`
        } else {
            SequenceCommentsOperation(sequenceID: sequenceID).queue() { error in
                self.delegate?.didUpdateCommentsWithPageType(.First)
            }
        }
        
        SequenceCommentsOperation(sequenceID: sequenceID).queue() { error in
            let followerCount = self.user.numberOfFollowers.integerValue
            if followerCount > 0 {
                // TODO: Change to KVO
                let countString = self.largeNumberFormatter.stringForInteger(followerCount)
                let labelString = NSLocalizedString("followers", comment:"")
                self.followersText = "\(countString) \(labelString)"
            } else {
                self.followersText = ""
            }
        }
        
        if let currentUserID = VUser.currentUser()?.remoteId.integerValue {
            SequenceUserInterationsOperation( sequenceID: sequenceID, userID: Int64(currentUserID) ).queue() { error in
                self.hasReposted =  true // VSequenceUserInteractions.hasReposted
            }
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
            
            if let sequence: VSequence? = PersistentStore().sync({ context in
                return context.findObjects( [ "remoteId" : nextSequenceId ] ).first
            }) where error == nil {
                success( sequence )
            } else {
                failure(error)
            }
        }
    }
}
