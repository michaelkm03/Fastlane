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
        remoteId            = stream.streamID
        itemType            = stream.type?.rawValue ?? itemType
        itemSubType         = stream.subtype?.rawValue ?? itemSubType
        name                = stream.name ?? name
        count               = stream.postCount ?? count
        previewImagesObject = stream.previewImagesObject
        
        if let previewImageAssets = stream.previewImageAssets {
            self.previewImageAssets = Set<VImageAsset>(previewImageAssets.flatMap {
                let imageAsset: VImageAsset = self.v_managedObjectContext.v_findOrCreateObject([ "imageURL" : $0.url.absoluteString ])
                imageAsset.populate( fromSourceModel: $0 )
                return imageAsset
                })
        }
        
        let streamChildren = VStreamChild.parseStreamItems( fromStream: stream, inManagedObjectContext: self.v_managedObjectContext )
        self.v_addObjects( streamChildren, to: "streamChildren" )
        
        let marqueeChildren = VStreamChild.parseMarqueeItems(fromStream: stream, inManagedObjectContext: self.v_managedObjectContext)
        self.v_addObjects( marqueeChildren, to: "marqueeChildren")
    }
}
