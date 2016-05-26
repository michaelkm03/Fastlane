//
//  VNotification+Parsable.swift
//  victorious
//
//  Created by Patrick Lynch on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VNotification: PersistenceParsable {
    
    func populate(fromSourceModel sourceModel: Notification) {
        createdAt       = sourceModel.createdAt
        subject         = sourceModel.subject
        updatedAt       = sourceModel.updatedAt ?? updatedAt
        body            = sourceModel.body ?? type
        type            = sourceModel.type ?? type
        imageURL        = sourceModel.imageURL ?? imageURL
        isRead          = sourceModel.isRead ?? isRead
        deepLink        = sourceModel.deeplink ?? deepLink
        
        self.user = v_managedObjectContext.v_findOrCreateObject( [ "remoteId" : sourceModel.user.id ] ) as VUser
        self.user.populate(fromSourceModel: sourceModel.user)
    }
}
