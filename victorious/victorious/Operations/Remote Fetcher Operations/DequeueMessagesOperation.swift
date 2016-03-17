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
    var mediaUrl: String?
    var mediaWidth: NSNumber?
    var mediaHeight: NSNumber?
    
    init(displayOrder: NSNumber) {
        self.displayOrder = displayOrder
    }
}

private let totalMessages = 0 //< Hack for testing

final class DequeueMessagesOperation: FetcherOperation, PaginatedOperation {
    
    let paginator: StandardPaginator
    
    required init(paginator: StandardPaginator = StandardPaginator()) {
        self.paginator = paginator
    }
    
    required convenience init(operation: DequeueMessagesOperation, paginator: StandardPaginator) {
        self.init(paginator: paginator)
    }
    
    override func main() {
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let otherUser: VUser = context.v_findOrCreateObject(
                [
                    "remoteId" : 3213,
                    "name" : "Gg",
                    "pictureUrl" : "http://media-dev-public.s3-website-us-west-1.amazonaws.com/23098f21be20502eccdf0af31ab14985/320x320.jpg"
                ]
            )
            otherUser.status = "test"
        
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context) else {
                return
            }
            
            var messagesCreated = [ChatMessage]()
            var displayOrder = totalMessages
            
            let messagesCount = 1 + Int(arc4random() % 2)
            for _ in 0..<messagesCount {
                let sender: VUser
                if arc4random() % 5 == 1 {
                    sender = currentUser
                } else {
                    sender = otherUser
                }
                
                let rnd = Int(arc4random() % UInt32(testMessageText.count) )
                let text = testMessageText[rnd]
                let message = ChatMessage(displayOrder: displayOrder++)
                message.sender = sender
                message.text = text
                message.postedAt = NSDate()
                
                if arc4random() % 10 > 7 || text.characters.isEmpty {
                    let rnd = Int(arc4random() % UInt32(sampleMedia.count) )
                    let media = sampleMedia[rnd]
                    message.mediaUrl = media["url"] as? String
                    message.mediaWidth = media["width"] as? Int
                    message.mediaHeight = media["height"] as? Int
                }
                
                messagesCreated.append(message)
            }
                    
            self.results = messagesCreated
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
    "I am so blue I'm greener than purple.",
    "",
    "I stepped on a Corn Flake, now I'm a Cereal Killer. 🎎 🎂",
    "Llamas eat sexy paper clips. 🌱",
    "Guess who's pregnant again!! Not me so take a deep 🍄 breath before you have a heart attack...",
    "ur profile picture is a car does this mean your a TRANSFORMER!!!",
    "I'm so awesome. 🍄🍄🍄🍄🍄🍄🍄",
    "",
    "I put a note on my mirror this morning. 🍄 It says \"objects are smaller than they appear.\"",
    "have 🎂 you ever wanted to 🎎 dress like the grim reaperV a🎎 nd go to a retirement home and tap on the windows!?comment below if you would or wouldn't 🌱",
    "BUT 🎂 my best friends think I'm completely insane! oh think if there were two of me...",
    "Wonders why I turn the radio down in my car while looking for an address, like it helps me see better lol:)",
    "OK just out of curiosity",
    "",
    "OK just out of curiosity, 🍄 why is it every time someone sees me smile they give me a smirk & ask what I am up to ??",
    "I know you are jealous.",
    "",
    "If your canoe is stuck in a tree with the headlights on, how many pancakes does it take to get to the moon?",
    "🌱 On a scale from one to ten what is your favourite 🍄 colour of the alphabet.",
    "Mom mom mom mommy mommy mom mom mom ma ma ma mummy mummy 🎎 mummy WHAT?! Hi, hahahahaha!",
    "Everyday a grape licks a friendly cow.",
    "",
    "Banana error. 🍘🍘🍘🎷🎸🎹",
    "I randomly said this to my friends and they said I needed mental help.",
    "That would be so funny if that was true! Laugh out loud",
    "Why would a 🍄 mushroom 🍄 scream Tacos? HAHA!",
    "Wow random humor is so funny",
    "I am going to the shop to buy some lemons and I am going to chuck them at a guy called Tom",
    "Laugh out 🍘 loud... This is my new motto!",
    "Lol Hilarious! I couldn't figure 🎎 out how to put some random sentences 🍄 in this site, so...",
    "BUNNY CRANKERS!",
    "CRUNCHY 🎎 BANANAS!",
    "A cranky old lady shoots pineapples with a machinegun.",
    "Chair number eleven is omni-present, much like candy.",
    "Whats more like a cucumber- cows, the number 2, or a math test eating your feet?",
    "okay here is a joke meh 🍘 friend told me (some people may not like it)",
]
