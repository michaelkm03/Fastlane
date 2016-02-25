//
//  LiveStreamOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class LiveStreamOperation: FetcherOperation, PaginatedOperation {
    
    let paginator: StandardPaginator
    let conversationID: Int
    
    required init(conversationID: Int, paginator: StandardPaginator = StandardPaginator()) {
        self.paginator = paginator
        self.conversationID = conversationID
        super.init()
        
        if self.paginator.pageNumber == 1 {
            LiveStreamOperationUpdate(conversationID: conversationID).before(self).queue()
        }
    }
    
    required convenience init(operation: LiveStreamOperation, paginator: StandardPaginator) {
        self.init(conversationID: operation.conversationID, paginator: paginator)
    }
    
    override func main() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            guard let conversation: VConversation = context.v_findObjects(["remoteId" : self.conversationID ]).first else {
                return
            }
            
            let predicate = self.paginator.paginatorPredicate
            self.results = conversation.messages?.filteredOrderedSetUsingPredicate( predicate ).array
        }
    }
}

final class LiveStreamOperationUpdate: FetcherOperation, PaginatedOperation {
    
    let paginator: StandardPaginator
    let conversationID: Int
    
    required init(conversationID: Int, paginator: StandardPaginator = StandardPaginator()) {
        self.paginator = paginator
        self.conversationID = conversationID
    }
    
    required convenience init(operation: LiveStreamOperationUpdate, paginator: StandardPaginator) {
        self.init(conversationID: operation.conversationID, paginator: paginator)
    }
    
    override func main() {
        
        let objectIDs: [NSManagedObjectID] = persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context),
                let conversation: VConversation = context.v_findObjects( ["remoteId" : self.conversationID ]).first else {
                return []
            }
            
            let user: VUser = context.v_findOrCreateObject([ "remoteId" : 3213, "name" : "Franky"])
            user.status = "test"
            conversation.user = user
            
            var messagesCreated = [VMessage]()
            var displayOrder = (conversation.messages?.lastObject as? VMessage)?.displayOrder.integerValue ?? 0
            
            let messagesCount = 1 + Int(arc4random() % 4)
            for _ in 0..<messagesCount {
                let sender: VUser
                if arc4random() % 5 == 1 {
                    sender = currentUser
                } else {
                    sender = user
                }
                
                let rnd = Int(arc4random() % UInt32(testMessageText.count) )
                let text = testMessageText[rnd]
                let message: VMessage = context.v_createObject()
                message.sender = sender
                message.text = text
                message.postedAt = NSDate()
                message.displayOrder = --displayOrder
                messagesCreated.append(message)
            }
            
            conversation.v_addObjects( messagesCreated, to: "messages")
            context.v_save()
            
            return messagesCreated.map { $0.objectID }
        }
        
        persistentStore.mainContext.v_performBlockAndWait() { context in
            self.results = objectIDs.flatMap {
                return context.objectWithID($0) as? VMessage
            }
        }
    }
}


private let testMessageText = [
    "I love you Ariana!",
    "You rocked at iHeartRadio!!",
    "OMG your so cute your dimple!  Why can't I look like you!",
    "I have no words",
    "I love you Ariana!",
    "You rocked at iHeartRadio!!  You rocked at iHeartRadio!!  You rocked at iHeartRadio!!  You rocked at iHeartRadio!!",
    "OMG your so cute your dimple!  Why can't I look like you!  OMG your so cute your dimple!  Why can't I look like you!  OMG your so cute your dimple!  Why can't I look like you!",
    "I have no words",
    "I love you Ariana!",
    "You rocked at iHeartRadio!!",
    "OMG your so cute your dimple!  Why can't I look like you!",
    "I have no words",
    "I love you Ariana!",
    "You rocked at iHeartRadio!!  You rocked at iHeartRadio!!  You rocked at iHeartRadio!!  You rocked at iHeartRadio!!",
    "OMG your so cute your dimple!  Why can't I look like you!  OMG your so cute your dimple!  Why can't I look like you!  OMG your so cute your dimple!  Why can't I look like you!",
    "I have no words"
]