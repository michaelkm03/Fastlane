//
//  UserModel.swift
//  victorious
//
//  Created by Jarod Long on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK

extension UserModel {
    
    // MARK: - Current user information
    
    var isCurrentUser: Bool {
        return id == VCurrentUser.user()?.remoteId.integerValue
    }
    
    // MARK: - VIP information
    
    var hasValidVIPSubscription: Bool {
        guard let endDate = vipStatus?.endDate where vipStatus?.isVIP == true else {
            return false
        }
        
        return endDate > NSDate()
    }
    
    func canView(content: ContentModel) -> Bool {
        return !content.isVIPOnly || hasValidVIPSubscription
    }
}
