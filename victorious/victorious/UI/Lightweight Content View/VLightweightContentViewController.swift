//
//  VLightweightContentViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 12/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public extension VLightweightContentViewController {
    
    public func fetchSequence( sequenceId sequenceId: String, completion:(VSequence?, NSError?) -> Void ) {
        if let sequenceID = Int64(sequenceId) {
            let op = SequenceFetchOperation( sequenceID: sequenceID )
            op.queue() { error in
                completion( op.sequence, error )
            }
        }
    }
}