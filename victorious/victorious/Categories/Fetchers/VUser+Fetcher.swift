//
//  VUser+Fetcher.swift
//  victorious
//
//  Created by Vincent Ho on 5/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension VUser {
    
    func isVIPValid() -> Bool {
        
        guard let vipEndDate = vipEndDate,
            let isVIPSubscriber = isVIPSubscriber?.boolValue else {
                return false
        }
        
        return vipEndDate > NSDate() && isVIPSubscriber
    }
    
    var badgeType: AvatarBadgeType {
        return v_avatarBadgeType == AvatarBadgeType.Verified.stringRepresentation ? .Verified : .None
    }

}
