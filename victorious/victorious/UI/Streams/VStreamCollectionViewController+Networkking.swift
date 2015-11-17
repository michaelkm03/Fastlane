//
//  VStreamCollectionViewController+Networkking.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

extension VStreamCollectionViewController {
    
    func likeSequence(sequence: VSequence, completion: ((Bool) -> Void)?) {
        LikeSequenceOperation( sequenceID: Int64(sequence.remoteId)! ).queue() { error in
            completion?( error == nil )
        }
    }
    
    func unlikeSequence(sequence: VSequence, completion: ((Bool) -> Void)?) {
        UnlikeSequenceOperation( sequenceID: Int64(sequence.remoteId)! ).queue() { error in
            completion?( error == nil )
        }
    }
}