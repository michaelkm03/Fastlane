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
        remoteId        = node.nodeID
        shareUrlPath    = node.shareUrlPath?.absoluteString ?? shareUrlPath
        
        if let assets = node.assets {
                let persistentAssets: [VAsset] = assets.flatMap {
                let asset: VAsset = self.v_managedObjectContext.v_createObject()
                asset.populate( fromSourceModel: $0 )
                return asset
            }
            self.assets = NSOrderedSet(array: persistentAssets)
        }
        
        if let interactions = node.interactions {
            let persistentInteractions: [VInteraction] = interactions.flatMap {
                let interaction: VInteraction = self.v_managedObjectContext.v_createObject()
                interaction.populate( fromSourceModel: $0 )
                return interaction
            }
            self.interactions = NSOrderedSet(array: persistentInteractions)
        }
    }
}
