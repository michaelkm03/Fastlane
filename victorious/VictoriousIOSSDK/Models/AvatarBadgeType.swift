//
//  AvatarBadgeType.swift
//  victorious
//
//  Created by Vincent Ho on 2/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

@objc public enum AvatarBadgeType: Int {
    case Verified
    case None
    
    public init(json: JSON) {
        if json["badge_type"].stringValue == "verified" {
            self = .Verified
        } else {
            self = .None
        }
    }
    
    public var stringRepresentation: String {
        switch self {
        case .Verified:
            return "verified"
        case .None:
            return ""
        }
    }
}
