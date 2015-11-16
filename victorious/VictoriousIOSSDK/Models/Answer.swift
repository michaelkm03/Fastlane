//
//  Answer.swift
//  victorious
//
//  Created by Patrick Lynch on 11/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Answer {
    public let isCorrect: Bool
    public let label: String
    public let mediaUrl: String
    public let remoteID: String
    public let thumbnailUrl: String
}

extension Answer {
    public init?(json: JSON) {
        guard let remoteID      = json["answer_id"].string,
            let label           = json["label"].string,
            let mediaUrl        = json["label_media_url"].string,
            let thumbnailUrl    = json["label_thumbnail_url"].string else {
                return nil
        }
        self.remoteID           = remoteID
        self.label              = label
        self.thumbnailUrl       = thumbnailUrl
        self.mediaUrl           = mediaUrl
        
        isCorrect               = Bool(json["is_correct"] ?? "") ?? false
    }
}
