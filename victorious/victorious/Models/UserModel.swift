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
        return vipStatus?.isVIP == true
    }
    
    func canView(content: ContentModel) -> Bool {
        return !content.isVIPOnly || hasValidVIPSubscription
    }
    
    // MARK: - Colors
    
    var color: UIColor {
        guard userModelColors.count > 0 else {
            assertionFailure("Found no user model colors.")
            return .whiteColor()
        }
        
        return userModelColors[id % userModelColors.count]
    }
}

private let userModelColors = [
    "B73E4D", "F72626", "F43A27", "F45A56", "F97855", "EF6622", "F7941E", "EDD354",
    "B7F76D", "48CC74", "129B12", "28E0C6", "00A79D", "ADE4F2", "55D6F9", "27AAE1",
    "1D7F99", "4573DB", "B0BFFF", "C3A5F2", "9463E0", "D462F9", "EA4BE3", "B835BC",
    "DD2A84", "ED2059", "F297C6", "E5558C", "F7197E", "A80760", "DDDDDD", "FFFFFF"
].flatMap {
    UIColor(rgbHexString: $0)
}
