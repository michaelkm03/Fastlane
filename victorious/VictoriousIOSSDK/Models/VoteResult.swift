//
//  VoteResult.swift
//  victorious
//
//  Created by Tian Lan on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct VoteResult {
    public let voteID: Int64
    public let voteCount: Int64
}

extension VoteResult {
    public init?(json: JSON) {
        guard let answerID = Int64(json["id"].stringValue) ?? Int64(json["answer_id"].stringValue),
            let count = json["count"].int64 ?? json["total_count"].int64 else {
                return nil
        }
        self.voteID = answerID
        self.voteCount = count
    }
}
