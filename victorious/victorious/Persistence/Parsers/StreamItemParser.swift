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
                return populateShelf(fromStreamItem: item, withUniqueIdentifier: uniqueElements, context: context)
                
            default:
                return nil
            }
        }
    }
    
    static private func populateShelf(fromStreamItem item: StreamItemType, withUniqueIdentifier identifier: [String : AnyObject], context: NSManagedObjectContext) -> Shelf? {
        switch item.subtype {
            
        case .Some(.User):
            guard let userShelf = item as? VictoriousIOSSDK.UserShelf else { return nil }
            let persistentUserShelf = context.v_findOrCreateObject(identifier) as UserShelf
            persistentUserShelf.populate(fromSourceShelf: userShelf)
            return persistentUserShelf
            
        case .Some(.Hashtag):
            guard let hashtagShelf = item as? VictoriousIOSSDK.HashtagShelf else { return nil }
            let persistentHashtagShelf = context.v_findOrCreateObject(identifier) as HashtagShelf
            persistentHashtagShelf.populate(fromSourceShelf: hashtagShelf)
            return persistentHashtagShelf
            
        case .Some(.Playlist):
            guard let listShelf = item as? VictoriousIOSSDK.ListShelf else { return nil }
            let persistentListShelf = context.v_findOrCreateObject(identifier) as ListShelf
            persistentListShelf.populate(fromSourceShelf: listShelf)
            return persistentListShelf
            
        default:
            guard let shelf = item as? VictoriousIOSSDK.Shelf else { return nil }
            let persistentShelf = context.v_findOrCreateObject(identifier) as Shelf
            persistentShelf.populate(fromSourceShelf: shelf)
            return persistentShelf
        }
    }
}
