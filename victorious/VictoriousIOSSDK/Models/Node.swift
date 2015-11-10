//
//  Node.swift
//  victorious
//
//  Created by Patrick Lynch on 11/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Node {
    public let nodeID: String
    public let shareUrlPath: String
    public let assets: [Asset]
    public let interactions: [Interaction]
}

extension Node {
    public init?(json: JSON) {
        guard let nodeID = json["node_id"].string else {
            return nil
        }
        self.nodeID     = nodeID
        
        shareUrlPath    = json["share_url"].string!
        assets          = (json["assets"].array ?? []).flatMap { Asset( json:$0 ) }
        interactions    = (json["interactions"].array ?? []).flatMap { Interaction( json:$0 ) }
    }
}
