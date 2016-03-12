//
//  VUser+AvatarBadgeType.swift
//  victorious
//
//  Created by Patrick Lynch on 3/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

@objc enum AvatarBadgeType: Int {
    case Verified
    case None
}

extension VUser {
    var badgeType: AvatarBadgeType {
        return (avatarBadgeType ?? "") == "verified" ? .Verified : .None
    }
}
