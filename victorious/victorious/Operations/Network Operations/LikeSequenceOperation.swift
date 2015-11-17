//
//  LikeSequenceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class SeqyenceLikeOperation: RequestOperation<SequenceLikeRequest> {
    
    let userIdentifier: AnyObject
    
    init( sequenceID: Int64, userIdentifier: AnyObject ) {
        super.init( request: SequenceLikeRequest() )
    }
}