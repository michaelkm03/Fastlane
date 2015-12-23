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
    
    static func parseStreamItems(fromStream stream: Stream, inManagedObjectContext context: NSManagedObjectContext) -> [VStreamItem] {
        guard let streamItems = stream.items where !streamItems.isEmpty else {
            return []
        }
        
        let flaggedIds = VFlaggedContent().flaggedContentIdsWithType(.StreamItem)
        let unflaggedStreamItems = streamItems.filter { !flaggedIds.contains( $0.streamItemID ) }
        
        return unflaggedStreamItems.flatMap { item in
            
            let uniqueElements: [String : AnyObject] = [
                "remoteId" : item.streamItemID,
                "streamId" : stream.streamID
            ]
            
            if let sequence = item as? Sequence {
                let persistentSequence = context.v_findOrCreateObject( uniqueElements ) as VSequence
                persistentSequence.populate( fromSourceModel: sequence )
                return persistentSequence
            
            } else if let stream = item as? Stream {
                let persistentStream = context.v_findOrCreateObject(uniqueElements) as VStream
                persistentStream.populate( fromSourceModel: stream )
                return persistentStream
            
            } else {
                return nil
            }
        }
    }
}
