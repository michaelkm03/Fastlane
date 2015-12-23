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
    public let sequenceID: String?
    public let answerID: Int64?
    public let totalCount: Int64?
}

extension PollResult {
    public init?(json: JSON) {
        answerID = Int64(json["answer_id"].stringValue)
        totalCount = Int64(json["total_count"].stringValue)
        sequenceID = json["sequence_id"].string
        
        if answerID == nil && totalCount == nil && sequenceID == nil {
            return nil
        }
    }
}
