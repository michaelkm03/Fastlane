//
//  AdBreak.swift
//  victorious
//
//  Created by Patrick Lynch on 11/6/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct AdBreak: JSONDeseriealizable {
    public let adSystemID: Int
    public let timeout: Int
    public let adTag: String?
}

extension AdBreak {
    public init?(json: JSON) {
        guard let adSystemID = json["ad_system_id"].int,
            let adTag = json["ad_tag"].string where adTag != "",
            let timeout = json["timeout"].int else {
                return nil
        }
        self.adSystemID = adSystemID
        self.timeout = timeout
        self.adTag = adTag
    }
}
