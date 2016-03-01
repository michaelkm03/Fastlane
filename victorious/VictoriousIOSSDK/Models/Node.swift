//
//  Node.swift
//  victorious
//
//  Created by Patrick Lynch on 11/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct Node {
    public let nodeID: Int
    public let shareUrlPath: NSURL?
    public let assets: [Asset]?
    public let interactions: [Interaction]?
}

extension Node {
    public init?(json: JSON) {
        guard let nodeID = Int(json["node_id"].stringValue) else {
            return nil
        }
        self.nodeID     = nodeID
        
        shareUrlPath    = NSURL(string: json["share_url"].stringValue)
        assets          = json["assets"].array?.flatMap { Asset( json:$0 ) }
        interactions    = json["interactions"].array?.flatMap { Interaction( json:$0 ) }
    }
}
