//
//  Avatar.swift
//  victorious
//
//  Created by Vincent Ho on 2/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Avatar {
    public let badgeType: String?
}

extension Avatar {
    public init?(json: JSON) {
        self.badgeType = json["badge_type"].string
    }
}
