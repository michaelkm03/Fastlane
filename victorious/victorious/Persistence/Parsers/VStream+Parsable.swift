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
    
    func populate( fromSourceModel sourceStream: Stream ) {
        apiPath                 = sourceStream.apiPath
        remoteId                = sourceStream.streamID
        
        itemType                = sourceStream.type?.rawValue ?? itemType
        itemSubType             = sourceStream.subtype?.rawValue ?? itemSubType
        name                    = sourceStream.name ?? name
        count                   = sourceStream.postCount ?? count
        previewImagesObject     = sourceStream.previewImagesObject ?? previewImagesObject
        trackingIdentifier      = sourceStream.trackingIdentifier ?? trackingIdentifier
        isUserPostAllowed       = sourceStream.isUserPostAllowed ?? isUserPostAllowed
        
        // Parse out the streamItems
        let sourceStreamItems = sourceStream.items ?? []
        parsePersistentStreamItems(
            fromStreamItems: sourceStreamItems,
            parentStream: sourceStream,
            context: v_managedObjectContext
        )
        
        if let textPostAsset = sourceStream.previewAsset where textPostAsset.type == .Text {
            let persistentAsset: VAsset = v_managedObjectContext.v_createObject()
            persistentAsset.populate(fromSourceModel: textPostAsset)
            previewTextPostAsset = persistentAsset
        }
    }
    
    private func parsePersistentStreamItems(fromStreamItems items: [StreamItemType], parentStream: Stream, context: NSManagedObjectContext) -> [VStreamItem] {
        
        let flaggedIds = VFlaggedContent().flaggedContentIdsWithType(.StreamItem)
        let unflaggedItems = items.filter { !flaggedIds.contains( $0.streamItemID ) }
        return unflaggedItems.flatMap { item in
            let uniqueElements: [String : AnyObject] = [ "remoteId" : item.streamItemID ]
            
            switch item.type {
                
            case .Some(.Sequence):
                guard let sequence = item as? Sequence else {
                    return nil
                }
                let persistentSequence = context.v_findOrCreateObject( uniqueElements ) as VSequence
                persistentSequence.populate( fromSourceModel: sequence)
                createStreamItemPointer(pointingTo: persistentSequence, withSourceModel: item)
                return persistentSequence
                
            case .Some(.Stream):
                guard let stream = item as? Stream else {
                    return nil
                }
                let persistentStream = context.v_findOrCreateObject(uniqueElements) as VStream
                persistentStream.populate( fromSourceModel: stream )
                createStreamItemPointer(pointingTo: persistentStream, withSourceModel: item)
                return persistentStream
                
            case .Some(.Shelf):
                
                guard let persistentShelf = shelf(fromStreamItem: item, withUniqueIdentifier: uniqueElements, context: context) else {
                    return nil
                }
                createStreamItemPointer(pointingTo: persistentShelf, withSourceModel: item)
                return persistentShelf
                
            default:
                return nil
            }
        }
    }
    
    private func shelf(fromStreamItem item: StreamItemType, withUniqueIdentifier identifier: [String: AnyObject], context: NSManagedObjectContext) -> Shelf? {
        
        switch item.subtype {
            
        case .Some(.User):
            guard let userShelf = item as? VictoriousIOSSDK.UserShelf else {
                return nil
            }
            let persistentUserShelf = context.v_findOrCreateObject(identifier) as UserShelf
            persistentUserShelf.populate(fromSourceShelf: userShelf)
            return persistentUserShelf
            
        case .Some(.Hashtag):
            guard let hashtagShelf = item as? VictoriousIOSSDK.HashtagShelf else {
                return nil
            }
            let persistentHashtagShelf = context.v_findOrCreateObject(identifier) as HashtagShelf
            persistentHashtagShelf.populate(fromSourceShelf: hashtagShelf)
            return persistentHashtagShelf
            
        case .Some(.Playlist):
            guard let listShelf = item as? VictoriousIOSSDK.ListShelf else {
                return nil
            }
            let persistentListShelf = context.v_findOrCreateObject(identifier) as ListShelf
            persistentListShelf.populate(fromSourceShelf: listShelf)
            return persistentListShelf
            
        default:
            guard let shelf = item as? VictoriousIOSSDK.Shelf else {
                return nil
            }
            let persistentShelf = context.v_findOrCreateObject(identifier) as Shelf
            persistentShelf.populate(fromSourceShelf: shelf)
            return persistentShelf
        }
     }
    
    private func createStreamItemPointer(pointingTo streamItem: VStreamItem, withSourceModel sourceModel: StreamItemType) {
        let uniqueInfo = ["streamParent": self, "streamItem": streamItem]
        let pointer: VStreamItemPointer = v_managedObjectContext.v_findOrCreateObject(uniqueInfo)
        if let sequence = sourceModel as? Sequence {
            pointer.populate(fromSourceModel: sequence )
        }
        v_addObject(pointer, to: "streamItemPointers")
    }
}
