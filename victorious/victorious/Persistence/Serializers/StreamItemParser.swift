//
//  StreamItemParser.swift
//  victorious
//
//  Created by Patrick Lynch on 12/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Parses an array of networking `[StreamItemType]` into an array of persisetnt `[VStreamItem]`
extension VStreamItem {
    
    static func parseStreamItems(streamItems: [StreamItemType], managedObjectContext: NSManagedObjectContext) -> [VStreamItem] {
        let flaggedIds = VFlaggedContent().flaggedContentIdsWithType(.StreamItem)
        let unflaggedStreamItems = streamItems.filter { !flaggedIds.contains(String($0.remoteID)) }
        
        return unflaggedStreamItems.flatMap {
            if let sequence = $0 as? Sequence {
                let persistentSequence = managedObjectContext.v_findOrCreateObject([ "remoteId" : String(sequence.sequenceID) ]) as VSequence
                persistentSequence.populate( fromSourceModel: sequence )
                return persistentSequence
            }
            else if let stream = $0 as? Stream {
                let persistentStream = managedObjectContext.v_findOrCreateObject([ "remoteId" : stream.streamID ]) as VStream
                persistentStream.populate( fromSourceModel: stream )
                return persistentStream
            }
            return nil
        }
    }
}