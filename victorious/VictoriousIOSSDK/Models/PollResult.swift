//
//  PollResult.swift
//  victorious
//
//  Created by Patrick Lynch on 12/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct PollResult {
    public let sequenceID: String?
    public let answerID: Int?
    public let totalCount: Int?
}

extension PollResult {
    public init?(json: JSON) {
        answerID = Int(json["answer_id"].stringValue)
        totalCount = Int(json["total_count"].stringValue)
        sequenceID = json["sequence_id"].string
        
        if answerID == nil && totalCount == nil && sequenceID == nil {
            return nil
        }
    }
}
