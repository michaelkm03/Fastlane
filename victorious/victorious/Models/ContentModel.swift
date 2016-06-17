//
//  ContentModel.swift
//  victorious
//
//  Created by Tian Lan on 5/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK

extension ContentModel {
    // MARK: - Author information
    
    var wasCreatedByCurrentUser: Bool {
        return author.id == VCurrentUser.user()?.remoteId.integerValue
    }
}
