//
//  VStream+PersistenceParsable.swift
//  victorious
//
//  Created by Patrick Lynch on 11/6/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VStream: PersistenceParsable {
    
    func populate( fromSourceModel stream: Stream ) {
        remoteId        = String(stream.remoteID)
        itemType        = stream.type?.rawValue ?? ""
        itemSubType     = stream.subtype?.rawValue ?? ""
        name            = stream.name
        count           = stream.postCount
        
        streamItems += stream.items.flatMap {
            let sequence: VSequence = self.dataStore.findOrCreateObject([ "remoteID" : String($0.remoteID) ])
            sequence.populate( fromSourceModel: $0 )
            return sequence
        }
    }
}