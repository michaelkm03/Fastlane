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
        
        let streamItems = VStreamItem.parseStreamItems( stream.items, context: self.persistentStoreContext)
        self.addObjects( streamItems, to: "streamItems" )
    }
}