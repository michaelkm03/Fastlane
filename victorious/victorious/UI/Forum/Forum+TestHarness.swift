//
//  ForumTestHarness.swift
//  victorious
//
//  Created by Patrick Lynch on 3/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

// FUTURE: remove from project before App Store deploy.

import Foundation
import VictoriousIOSSDK

private var debugTimer = VTimerManager()

extension ForumViewController {
    private static let defaultStageContentLength: Double = 5
    
    func debug_startGeneratingMessages(interval interval: NSTimeInterval) {
        VTimerManager.addTimerManagerWithTimeInterval(interval,
            target: self,
            selector: #selector(debug_createMessages),
            userInfo: nil,
            repeats: true,
            toRunLoop: NSRunLoop.mainRunLoop(),
            withRunMode: NSRunLoopCommonModes
        )
        debug_createMessages()
    }
    
    private func randomText() -> String {
        let rnd = Int(arc4random() % UInt32(testMessageText.count) )
        return testMessageText[rnd]
    }
    
    private func randPreviewImage() -> ImageAsset {
        let rnd = Int(arc4random() % UInt32(previewImageURLs.count))
        let string = previewImageURLs[rnd]
        return ImageAsset(mediaMetaData: MediaMetaData(url: NSURL(string: string)!, size: CGSize(width: Double(arc4random() % 100), height: Double(arc4random() % 100))))
    }
    
    private func randName() -> String {
        let rnd = Int(arc4random() % UInt32(names.count) )
        return names[rnd]
    }
    
    private func randAsset() -> ContentMediaAsset {
        let rnd = Int(arc4random() % UInt32(sampleMedia.count) )
        let json = JSON(sampleMedia[rnd])
        return ContentMediaAsset(forumJSON: json)!
    }
    
    func debug_createMessages() {
        let text: String?
        let previewImage: ImageAsset?
        var type = ContentType.text
        
        if arc4random() % 10 > 8 {
            text = randomText()
            previewImage = randPreviewImage()
            type = .image
        } else if arc4random() % 10 > 2 {
            text = randomText()
            previewImage = nil
        } else {
            text = nil
            type = .image
            previewImage = randPreviewImage()
        }
        
        let content = Content(
            createdAt: NSDate(),
            text: (text == nil) ? nil : "\(totalCount) :: \(text!)",
            previewImages: [previewImage].flatMap { $0 },
            type: type, 
            author: User(
                id: 1000 + Int(arc4random() % 9999),
                name: randName(),
                previewImages: [randPreviewImage()]
            )
        )
        
        totalCount += 1
        broadcast(.appendContent([content]))
    }
    
    func debug_createStageEvents() {
        stageNext()
    }
    
    func stageNext() {
        stageCount = stageCount % sampleStageImageContents.count
        let next = sampleStageImageContents[stageCount]
        let contentType = ContentType(rawValue: next["type"]!)!
        let source = next["source"]

        var assets: [ContentMediaAssetModel] = []
        var previewAsset = randPreviewImage()
        if let id = next["id"] {
            let parameters = ContentMediaAsset.LocalAssetParameters(contentType: contentType, remoteID: id, source: source)
            assets.append(ContentMediaAsset(initializationParameters: parameters)!)
        }
        else if (contentType != .text) {
            let url = NSURL(string: next["url"]!)!
            let parameters = ContentMediaAsset.RemoteAssetParameters(contentType: contentType, url: url, source: source)
            assets.append(ContentMediaAsset(initializationParameters: parameters)!)
            if contentType == .image {
                previewAsset = ImageAsset(mediaMetaData: MediaMetaData(url: url, size: CGSizeMake(100, 100)))
            }
        }
        
        let content = Content(
            id: String(1000 + Int(arc4random() % 9999)),
            type: contentType,
            text: next["text"] ?? randomText(),
            assets: assets,
            previewImages: [previewAsset],
            author: User(
                id: 1000 + Int(arc4random() % 9999),
                name: randName(),
                previewImages: [randPreviewImage()]
            )
        )
        stage?.addContent(content)
        stageCount += 1
        
        let time = next["length"] != nil ? Double(next["length"]!)! : ForumViewController.defaultStageContentLength
        
        VTimerManager.addTimerManagerWithTimeInterval(
            time,
            target: self,
            selector: #selector(stageNext),
            userInfo: nil,
            repeats: false,
            toRunLoop: NSRunLoop.mainRunLoop(),
            withRunMode: NSRunLoopCommonModes
        )
    }

}

private var stageCount = 0
private var totalCount = 0

private let sampleStageImageContents = [
    [
        "type": "image",
        "url": "http://sportsup365.com/wp-content/uploads/2015/12/usatsi_8903306.jpg",
        "length": "10"
    ],
    [
        "type": "image",
        "url": "http://www.koco.com/image/view/-/36170342/medRes/1/-/maxh/460/maxw/620/-/hwy60t/-/westbrook-jpg--1-.jpg"
    ],
    [
        "type": "image",
        "url": "http://images.christianpost.com/full/88618/big-bang-theory.png"
    ],
    [
        "type": "gif",
        "url": "https://media.giphy.com/media/l41Yi2XOcNZ2lvTGw/giphy.mp4",
        "length": "15"
    ],
    [
        "type": "gif",
        "url": "https://media.giphy.com/media/lJh4drC6QTkkg/giphy.mp4"
    ],
    [
        "type": "video",
        "url": "http://media-dev-public.s3-website-us-west-1.amazonaws.com/852ced0666ee143e1d91b987daa8df6e/playlist.m3u8"
    ],
    [
        "type": "video",
        "url": "http://media-dev-public.s3-website-us-west-1.amazonaws.com/36170da86ad3933a86edd9bff9b21846/playlist.m3u8",
        "length": "15"
    ],
    [
        "type": "video",
        "source": "youtube",
        "id": "aL33-XfVccg",
        "length": "30"
        ],
    [
        "type": "video",
        "source": "youtube",
        "id": "OV0wOGUFZdw",
        "length": "30"
    ],
    [
        "type": "video",
        "source": "youtube",
        "id": "hgb8Jofr5ew",
        "length": "30"
    ],
    [
        "type" : "text",
        "text" : "Stage post text test content"
    ],
    [
        "type" : "text",
        "text" : "VIP Event happening now! Switch to VIP chat to check it out!"
    ],
    [
        "type" : "text",
        "text" : "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation "
    ]
]

private let sampleMedia = [
    [
        "type": "image",
        "url": "http://www.ducatiusa.com/cms-web/upl/MediaGalleries/939/MediaGallery_939430/Color_M-821_White_01_1067x600.jpg"
    ], [
        "type": "image",
        "url": "http://coolspotters.com/files/photos/444434/ducati-streetfighter-s-profile.png"
    ], [
        "type": "image",
        "url": "http://kickstart.bikeexif.com/wp-content/uploads/2013/09/ducati-monster-1100.jpg"
    ], [
        "type": "image",
        "url": "http://i.telegraph.co.uk/multimedia/archive/02963/Monster-821-1_2963300b.jpg"
    ], [
        "type": "gif",
        "url": "https://media3.giphy.com/media/6qalZjXQlpoGI/giphy.mp4"
    ]
]

private let names = [
    "Carl", "James", "Micelle", "Franky", "Bernadette", "Julia", "Patrick", "Sebastian", "Sharif"
]

private let previewImageURLs = [
    "http://40.media.tumblr.com/c88901101bc29bdeb4cd4c78c660b5c5/tumblr_nvmcod4W7m1ufrlieo1_500.png",
    "http://40.media.tumblr.com/3b9c703debacefbb7d7550b12c0de713/tumblr_nvmcqdVZAG1ufrlieo1_r1_500.png",
    "http://41.media.tumblr.com/1ffa6516e70d676b4c471f2ad25192a0/tumblr_nz04pmrWBN1ufrlieo1_500.png"
]

private let testMessageText = [
    "I am so blue I'm greener than purple.",
    "I stepped on a Corn Flake, now I'm a Cereal Killer. 🎎 🎂",
    "Llamas eat sexy paper clips. 🌱",
    "Guess who's pregnant again!! Not me so take a deep 🍄 breath before you have a heart attack...",
    "ur profile picture is a car does this mean your a TRANSFORMER!!!",
    "I'm so awesome. 🍄🍄🍄🍄🍄🍄🍄",
    "I put a note on my mirror this morning. 🍄 It says \"objects are smaller than they appear.\"",
    "have 🎂 you ever wanted to 🎎 dress like the grim reaperV a🎎 nd go to a retirement home and tap on the windows!?comment below if you would or wouldn't 🌱",
    "BUT 🎂 my best friends think I'm completely insane! oh think if there were two of me...",
    "Wonders why I turn the radio down in my car while looking for an address, like it helps me see better lol:)",
    "OK just out of curiosity",
    "OK just out of curiosity, 🍄 why is it every time someone sees me smile they give me a smirk & ask what I am up to ??",
    "I know you are jealous.",
    "If your canoe is stuck in a tree with the headlights on, how many pancakes does it take to get to the moon?",
    "🌱 On a scale from one to ten what is your favourite 🍄 colour of the alphabet.",
    "Mom mom mom mommy mommy mom mom mom ma ma ma mummy mummy 🎎 mummy WHAT?! Hi, hahahahaha!",
    "Everyday a grape licks a friendly cow.",
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
