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
        remoteId        = stream.streamID
        itemType        = stream.type?.rawValue ?? itemType
        itemSubType     = stream.subtype?.rawValue ?? itemSubType
        name            = stream.name ?? name
        count           = stream.postCount ?? count
        previewImagesObject = stream.previewImagesObject
        
        let streamItems = VStreamItem.parseStreamItems( fromStream: stream, inManagedObjectContext: self.v_managedObjectContext )
        self.v_addObjects( streamItems, to: "streamItems" )
        
        let marqueeItems = VStreamItem.parseMarqueeItems(fromStream: stream, inManagedObjectContext: self.v_managedObjectContext)
        self.v_addObjects(marqueeItems, to: "marqueeItems")
    }
}
