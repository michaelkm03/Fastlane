//
//  DequeueMessagesOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ChatMessage: NSObject, PaginatedObjectType {
    var displayOrder: NSNumber
    var sender: VUser!
    var text: String?
    var postedAt: NSDate!
    var media: ForumMedia?
    
    init(displayOrder: NSNumber) {
        self.displayOrder = displayOrder
    }
}

private var totalMessages = 0 //< Hack for testing

final class DequeueMessagesOperation: FetcherOperation, PaginatedOperation {
    
    let paginator: StandardPaginator
    let events: [ForumEvent]
    
    required init(events: [ForumEvent], paginator: StandardPaginator = StandardPaginator()) {
        self.paginator = paginator
        self.events = events
    }
    
    required convenience init(operation: DequeueMessagesOperation, paginator: StandardPaginator) {
        self.init(events: operation.events, paginator: paginator)
    }
    
    override func main() {
        
        persistentStore.mainContext.v_performBlockAndWait() { context in
            let userData = [
                "remoteId" : 3213,
                "name" : "Gg",
                "pictureUrl" : "http://media-dev-public.s3-website-us-west-1.amazonaws.com/23098f21be20502eccdf0af31ab14985/320x320.jpg"
            ]
            let otherUser: VUser = context.v_findOrCreateObject(userData)
            otherUser.status = "test"
            
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context) else {
                return
            }
            
            var messages = [ChatMessage]()
            for event in self.events {
                let sender: VUser
                if arc4random() % 5 == 1 {
                    sender = currentUser
                } else {
                    sender = otherUser
                }
                
                let message = ChatMessage(displayOrder: totalMessages++)
                message.sender = sender
                message.text = event.messageText
                message.postedAt = NSDate()
                message.media = event.media
                messages.append(message)
                totalMessages += 1
            }
            
            self.results = messages
            context.v_save()
        }
    }
}
