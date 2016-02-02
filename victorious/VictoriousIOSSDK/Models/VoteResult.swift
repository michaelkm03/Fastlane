//
//  VoteResult.swift
//  victorious
//
//  Created by Tian Lan on 2/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct VoteResult {
    public let voteID: String
    public let voteCount: Int
    
    public init?(json: JSON) {
        guard let id = json["id"].string,
            let count = json["count"].int else {
                return nil
        }
        self.voteID = id
        self.voteCount = count
    }
}
