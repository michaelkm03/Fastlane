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
    public let sequenceID: Int64
    public let answerID: Int64
    
    public init(sequenceID: Int64, answerID: Int64) {
        self.sequenceID = sequenceID
        self.answerID = answerID
    }
}

extension PollResult {
    public init?(json: JSON) {
        guard let sequenceID = Int64(json["sequence_id"].stringValue),
            let answerID = Int64(json["answer_id"].stringValue) else {
                return nil
        }
        self.sequenceID = sequenceID
        self.answerID = answerID
    }
}
