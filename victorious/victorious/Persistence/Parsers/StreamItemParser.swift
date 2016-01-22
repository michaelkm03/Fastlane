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
        
        return populatePersistentModels(fromStreamItems: unflaggedStreamItems, stream: stream, context: context)
    }
    
    static func parseMarqueeItems(fromStream stream: Stream, inManagedObjectContext context: NSManagedObjectContext) -> [VStreamItem] {
        guard let marqueeItems = stream.marqueeItems where !marqueeItems.isEmpty else {
            return []
        }
        
        return populatePersistentModels(fromStreamItems: marqueeItems, stream: stream, context: context)
    }
    
    static private func populatePersistentModels(fromStreamItems items: [StreamItemType], stream: Stream, context: NSManagedObjectContext) -> [VStreamItem] {
        
        return items.flatMap { item in
            
            let uniqueElements: [String : AnyObject] = [
                "remoteId" : item.streamItemID,
                "streamId" : stream.streamID
            ]
            
            switch item.type {
                
            case .Some(.Sequence):
                guard let sequence = item as? Sequence else { return nil }
                let persistentSequence = context.v_findOrCreateObject( uniqueElements ) as VSequence
                persistentSequence.populate( fromSourceModel: sequence )
                return persistentSequence
                
            case .Some(.Stream):
                guard let stream = item as? Stream else { return nil }
                let persistentStream = context.v_findOrCreateObject(uniqueElements) as VStream
                persistentStream.populate( fromSourceModel: stream )
                return persistentStream
                
            case .Some(.Shelf):
                guard let shelf = item as? Stream else { return nil }
                let persistentShelf = context.v_findOrCreateObject(uniqueElements) as Shelf
                persistentShelf.populate(fromSourceModel: shelf)
                persistentShelf.streamUrl = stream.streamUrl ?? ""
                persistentShelf.title = stream.title ?? ""
                return persistentShelf
                
            default:
                return nil
            }
        }
    }
}
