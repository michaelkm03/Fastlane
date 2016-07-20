//
//  AvatarBadgeType.swift
//  victorious
//
//  Created by Vincent Ho on 2/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

public enum AvatarBadgeType {
    case verified
    
    public init?(json: JSON) {
        if json["badge_type"].stringValue == "verified"  || json["verified"].bool == true {
            self = .verified
        } else {
            return nil
        }
    }
    
    public var stringRepresentation: String {
        switch self {
            case .verified: return "verified"
        }
    }
}
