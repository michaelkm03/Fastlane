//
//  VStream+Serializable.swift
//  victorious
//
//  Created by Patrick Lynch on 11/6/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VStream: DataStoreObject {
    // Will need to implement `entityName` when +RestKit categories are removed
}

extension VStream: Serializable {
    
    func serialize( stream: Stream, dataStore: DataStore ) {
        remoteId        = String(stream.remoteId)
        itemType        = stream.type
        itemSubType     = stream.subtype
        name            = stream.name
        count           = stream.postCount
        
        streamItems += stream.items.flatMap {
            let sequence: VSequence = dataStore.findOrCreateObject([ "remoteId" : String($0.remoteId) ])
            sequence.serialize( $0, dataStore: dataStore )
            return sequence
        }
    }
}