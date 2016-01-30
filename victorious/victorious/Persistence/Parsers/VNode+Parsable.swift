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
        self.remoteId = node.nodeID
        
        if assets.count == 0 && !node.assets.isEmpty {
            assets = NSOrderedSet( array: node.assets.flatMap {
                let asset: VAsset = self.v_managedObjectContext.v_createObject()
                asset.populate( fromSourceModel: $0 )
                return asset
                })
        }
        
        if interactions.count == 0 && !node.interactions.isEmpty {
            interactions = NSOrderedSet( array: node.interactions.flatMap {
                let interaction: VInteraction = self.v_managedObjectContext.v_createObject()
                interaction.populate( fromSourceModel: $0 )
                return interaction
                })
        }
    }
}
