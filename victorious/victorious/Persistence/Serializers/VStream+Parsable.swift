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
        itemType        = stream.type.rawValue ?? ""
        itemSubType     = stream.subtype.rawValue ?? ""
        name            = stream.name
        count           = stream.postCount
        
        let flaggedContent = VFlaggedContent()
        let allStreamItems: [VStreamItem] = stream.items.flatMap {
            if let sequence = $0 as? Sequence {
                let persistentSequence = self.persistentStoreContext.findOrCreateObject([ "remoteId" : String(sequence.sequenceID) ]) as VSequence
                persistentSequence.populate( fromSourceModel: sequence )
                return persistentSequence
            }
            else if let stream = $0 as? Stream {
                let persistentStream = self.persistentStoreContext.findOrCreateObject([ "remoteId" : stream.streamID ]) as VStream
                persistentStream.populate( fromSourceModel: stream )
                return persistentStream
            }
            return nil
        }
        streamItems += flaggedContent.commentsAfterStrippingFlaggedItems(allStreamItems) as? [VStreamItem] ?? []
    }
}