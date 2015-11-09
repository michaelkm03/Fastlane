//
//  VNode+Serializable.swift
//  victorious
//
//  Created by Patrick Lynch on 11/6/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VNode: DataStoreObject {
    // Will need to implement `entityName` when +RestKit categories are removed
}

extension VNode: Serializable {
    
    func serialize( node: Node, dataStore: DataStore ) {
        guard let remoteId = Int(node.nodeId) else {
            return
        }
        self.remoteId = NSNumber(integer: remoteId)
        
        assets = Optional(assets) + node.assets.flatMap {
            let asset: VAsset = dataStore.findOrCreateObject([ "remoteId" : Int($0.assetId) ])
            asset.serialize( $0, dataStore: dataStore )
            return asset
        }
    }
}
