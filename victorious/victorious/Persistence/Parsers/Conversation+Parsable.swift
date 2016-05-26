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
        
        if self.user == nil {
            self.user = v_managedObjectContext.v_findOrCreateObject( [ "remoteId" : sourceModel.otherUser.id ] ) as VUser
        }
        self.user?.populate(fromSourceModel: sourceModel.otherUser)
    }
}
