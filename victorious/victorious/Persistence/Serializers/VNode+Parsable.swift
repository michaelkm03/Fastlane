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
        guard let remoteID = Int(node.nodeID) else {
                return
        }
        self.remoteId = NSNumber(integer: remoteID)
        
        assets = Optional(assets) + node.assets.flatMap {
            let asset: VAsset = self.dataStore.findOrCreateObject([ "remoteID" : Int($0.assetID) ])
            asset.populate( fromSourceModel: $0 )
            return asset
        }
    }
}
