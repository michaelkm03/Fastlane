//
//  PollAnswer.swift
//  victorious
//
//  Created by Tian Lan on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct PollAnswer {
    public let sequenceID: Int64
    public let answerID: Int64
    
    public init(sequenceID: Int64, answerID: Int64) {
        self.sequenceID = sequenceID
        self.answerID = answerID
    }
}

extension PollAnswer {
    public init?(json: JSON) {
        guard let sequenceID = Int64(json["sequence_id"].stringValue),
            let answerID = Int64(json["answer_id"].stringValue) else {
                return nil
        }
        self.sequenceID = sequenceID
        self.answerID = answerID
    }
}
