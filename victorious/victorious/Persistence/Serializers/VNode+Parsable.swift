//
//  VNode+PersistenceParsable.swift
//  victorious
//
//  Created by Patrick Lynch on 11/6/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VNode: PersistenceParsable {
    
    func populate( fromSourceModel node: Node ) {
        guard let remoteID = Int64(node.nodeID) else {
            return
        }
        self.remoteId = NSNumber(longLong: remoteID)
        
        assets = NSOrderedSet( array: node.assets.flatMap {
            let uniqueElements = [ "data" : $0.data ]
            let asset: VAsset = self.v_managedObjectContext.v_findOrCreateObject( uniqueElements )
            asset.populate( fromSourceModel: $0 )
            return asset
        })
        
        interactions = NSOrderedSet( array: node.interactions.flatMap {
            let uniqueElements = [ "remoteId" : NSNumber(longLong: $0.remoteID) ]
            let interaction: VInteraction = self.v_managedObjectContext.v_findOrCreateObject( uniqueElements )
            interaction.populate( fromSourceModel: $0 )
            return interaction
        })
    }
}
