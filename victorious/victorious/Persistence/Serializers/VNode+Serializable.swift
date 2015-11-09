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
        guard let remoteID = Int(node.nodeID) else {
            return
        }
        self.remoteId = NSNumber(integer: remoteID)
        
        assets = Optional(assets) + node.assets.flatMap {
            let asset: VAsset = dataStore.findOrCreateObject([ "remoteID" : Int($0.assetID) ])
            asset.serialize( $0, dataStore: dataStore )
            return asset
        }
    }
}
