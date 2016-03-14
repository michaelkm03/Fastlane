//
//  DequeueMessagesOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class DequeueMessagesOperation: FetcherOperation, PaginatedOperation {
    
    let paginator: StandardPaginator
    let conversationID: Int
    
    required init(conversationID: Int, paginator: StandardPaginator = StandardPaginator()) {
        self.paginator = paginator
        self.conversationID = conversationID
    }
    
    required convenience init(operation: DequeueMessagesOperation, paginator: StandardPaginator) {
        self.init(conversationID: operation.conversationID, paginator: paginator)
    }
    
    override func main() {
        
        let objectIDs: [NSManagedObjectID] = persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context),
                let conversation: VConversation = context.v_findObjects( ["remoteId" : self.conversationID ]).first else {
                    return []
            }
            
            let user: VUser = context.v_findOrCreateObject(
                [
                    "remoteId" : 3213,
                    "name" : "Gg",
                    "pictureUrl" : "http://media-dev-public.s3-website-us-west-1.amazonaws.com/23098f21be20502eccdf0af31ab14985/320x320.jpg"
                ]
            )
            user.status = "test"
            conversation.user = user
            
            var messagesCreated = [VMessage]()
            var displayOrder = conversation.messages?.count ?? 0
            
            let messagesCount = 1 + Int(arc4random() % 2)
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
                message.displayOrder = displayOrder++
                
                if arc4random() % 10 > 7 || text.characters.isEmpty {
                    let rnd = Int(arc4random() % UInt32(sampleMedia.count) )
                    let media = sampleMedia[rnd]
                    message.mediaUrl = media["url"] as? String
                    message.mediaWidth = media["width"] as! Int
                    message.mediaHeight = media["height"] as! Int
                }
                
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

private let sampleMedia = [
    [
        "url" : "http://www.ducatiusa.com/cms-web/upl/MediaGalleries/939/MediaGallery_939430/Color_M-821_White_01_1067x600.jpg",
        "width" : 1067,
        "height" : 600
    ],[
        "url" : "http://kickstart.bikeexif.com/wp-content/uploads/2013/09/ducati-monster-1100.jpg",
        "width" : 625,
        "height" : 417
    ],[
        "url" : "http://i.telegraph.co.uk/multimedia/archive/02963/Monster-821-1_2963300b.jpg",
        "width" : 620,
        "height" : 387
    ]
]

private let testMessageText = [
    "Don't Lie!! Freaky Ass",
    "",
    "I'm so awesome because i can trip 🎎 over flat surfaces and fall up the stairs. Now that's a talented skill right 🎂 there :D I can also fall up. Yep",
    "Shanaynay: Ahh!\nShane: What!?\nShanaynay: Was I sleepin?\nShane:Yes!\n Shanaynay: Did you try to touch me? \nShane: No!\nShanaynay: 🎂 Don't Lie!! Freaky Ass 🌱",
    "Guess who's pregnant again!! Not me so take a deep 🍄 breath before you have a heart attack...",
    "ur profile picture is a car does this mean your a TRANSFORMER!!!",
    "I'm so awesome. 🍄🍄🍄🍄🍄🍄🍄",
    "",
    "I put a note on my mirror this morning. 🍄 It says \"objects are smaller than they appear.\"",
    "have 🎂 you ever wanted to dress like the grim reaperV a🎎 nd go to a retirement home and tap on the windows!?comment below if you would or wouldn't 🌱",
    "BUT 🎂 my best friends think I'm completely insane! oh think if there were two of me...",
    "Wonders why I turn the radio down in my car while looking for an address, like it helps me see better lol:)",
    "OK just out of curiosity",
    "",
    "OK just out of curiosity, 🍄 why is it every time someone sees me smile they give me a smirk & ask what I am up to ??",
    "I know you are jealous.",
    "",
    "I have an awesome jacket that allows me to hug myself and you don't",
    "No 🌱, I did not trip, I attacked the floor with my Awesome NINJA skills",
    "mom mom mom mommy mommy mom mom mom ma ma ma mummy mummy 🎎 mummy WHAT?! hi hahahahaha",
    "HOLD MY HAND!",
    "",
    "Officer: Any last requests?\n🍘🍘🍘Man in jail cell: Yes.Hold my, 🎷🎸🎹 hold my, hold my, HOLD MY HAND!"
]
