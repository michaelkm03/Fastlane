//
//  Interaction.swift
//  victorious
//
//  Created by Patrick Lynch on 11/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Interaction {
    public let question: String
    public let remoteID: Int64
    public let startTime: Double
    public let timeout: Double
    public let type: String
    public let displayOrder: Int
    public let answers: [Answer]
}

extension Interaction {
    public init?(json: JSON) {
        guard let displayOrder  = json["display_order"].int,
            let remoteID        = Int64(json["interaction_id"].string ?? "") ,
            let question        = json["question"].string,
            let type            = json["type"].string else {
            return nil
        }
        self.remoteID           = remoteID
        self.displayOrder       = displayOrder
        self.type               = type
        self.question           = question
        
        startTime               = Double(json["start_time"].string ?? "") ?? 0.0
        timeout                 = Double(json["timeout"].string ?? "") ?? 0.0
        answers                 = (json["answers"].array ?? []).flatMap { Answer( json:$0 ) }
    }
}
