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
        let sequenceFetchOperation = SequenceFetchOperation( sequenceID: Int64(self.sequence.remoteId)! )
        sequenceFetchOperation.mainQueueCompletionBlock = { error in
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
        sequenceFetchOperation.queue()
    }
}
