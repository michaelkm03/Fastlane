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
    
    func populate( fromSourceModel conversation: Conversation ) {
        isRead      = conversation.isRead
        postedAt    = conversation.postedAt
        remoteId    = conversation.conversationID
        messages    = NSOrderedSet()
    }
}