//
//  PollResult.swift
//  victorious
//
//  Created by Patrick Lynch on 12/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct PollResult {
    public let sequenceID: Int64?
    public let answerID: Int64
    public let totalCount: Int64?
}

extension PollResult {
    public init?(json: JSON) {
        guard let answerID = Int64(json["answer_id"].stringValue) else {
                return nil
        }
        self.answerID = answerID
        
        totalCount = json["total_count"].int64
        sequenceID = json["sequence_id"].int64
    }
}
