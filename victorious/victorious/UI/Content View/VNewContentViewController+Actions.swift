//
//  VNewContentViewController+Actions.swift
//  victorious
//
//  Created by Patrick Lynch on 11/24/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

extension VNewContentViewController {
    
    func flagSequence( sequnece: VSequence, completion: ((NSError?)->())? = nil ) {
        guard let sequenceID = Int64(sequnece.remoteId) else {
            completion?( NSError(domain: "", code: -1, userInfo: nil) )
            return
        }
        
        FlagSequenceOperation(sequenceID: sequenceID ).queue() { error in
            completion?( error )
        }
    }
    
    func deleteSequence( sequnece: VSequence, completion: ((NSError?)->())? = nil ) {
        guard let sequenceID = Int64(sequnece.remoteId) else {
            completion?( NSError(domain: "", code: -1, userInfo: nil) )
            return
        }
        
        DeleteSequenceOperation(sequenceID: sequenceID ).queue() { error in
            completion?( error )
        }
    }
}