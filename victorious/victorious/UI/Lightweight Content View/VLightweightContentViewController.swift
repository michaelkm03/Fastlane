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
        
        let op = SequenceFetchOperation( sequenceID: sequenceId )
        op.queue() { error in
            completion( op.result, error )
        }
    }
}
