//
//  LiveStreamOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

let testMessageText = [
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

final class LiveStreamOperation: RequestOperation, PaginatedOperation {
    
    let request: StreamRequest
    
    required init( request: StreamRequest ) {
        self.request = request
    }
    
    override convenience init() {
        self.init( request: StreamRequest(apiPath: "", sequenceID: nil)! )
    }
    
    override func main() {
        
        var displayOrder = self.request.paginator.displayOrderCounterStart
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            let sender: VUser
            if arc4random() % 10 > 3 {
                sender = context.v_findOrCreateObject([ "remoteId" : 3213, "name" : "Franky" ])
            } else {
                sender = VCurrentUser.user(inManagedObjectContext: context)!
            }
                
            for text in testMessageText {
                let message: VMessage = context.v_createObject()
                message.sender = sender
                message.senderUserId = sender.remoteId
                message.text = text
                message.postedAt = NSDate()
                message.displayOrder = displayOrder++
            }
            
            context.v_save()
        }
    }
}

final class LiveStreamOperationUpdate: RequestOperation, PaginatedOperation {
    
    let request: StreamRequest
    
    required init( request: StreamRequest ) {
        self.request = request
    }
    
    override convenience init() {
        self.init( request: StreamRequest(apiPath: "", sequenceID: nil)! )
    }
    
    override func main() {
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            if arc4random() % 10 > 2 {
                var results = [AnyObject]()
                for _ in 0..<Int(arc4random() % 4) {
                    let rnd = Int(arc4random() % UInt32(testMessageText.count) )
                    let text = testMessageText[rnd]
                    let sender: VUser = context.v_findOrCreateObject([ "remoteId" : 3213, "name" : "Franky" ])
                    let message: VMessage = context.v_createObject()
                    message.sender = sender
                    message.senderUserId = sender.remoteId
                    message.text = text
                    message.postedAt = NSDate()
                    results.append( message )
                }
                self.results = results
            } else {
                self.results = []
            }
        }
    }
}
