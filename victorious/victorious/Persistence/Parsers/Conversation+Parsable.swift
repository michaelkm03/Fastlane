//
//  Conversation+Parsable.swift
//  victorious
//
//  Created by Patrick Lynch on 11/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VConversation: PersistenceParsable {
    
    func populate( fromSourceModel sourceModel: Conversation ) {
        isRead              = sourceModel.isRead ?? isRead
        postedAt            = sourceModel.postedAt ?? postedAt
        remoteId            = sourceModel.conversationID ?? remoteId
        lastMessageText     = sourceModel.previewMessageText ?? lastMessageText
        
        if let otherUser = sourceModel.otherUser {
            if self.user == nil {
                self.user = v_managedObjectContext.v_findOrCreateObject( [ "remoteId" : otherUser.userID ] ) as VUser
            }
            self.user.populate(fromSourceModel: otherUser)
        }
    }
}