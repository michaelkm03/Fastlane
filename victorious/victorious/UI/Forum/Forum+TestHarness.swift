//
//  ForumTestHarness.swift
//  victorious
//
//  Created by Patrick Lynch on 3/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

private var debugTimer = VTimerManager()

extension ForumViewController {
    
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
        return ImageAsset(mediaMetaData: MediaMetaData(url: NSURL(string: string)!))
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
        let asset: ContentMediaAsset?
        
        if arc4random() % 10 > 8 {
            text = randomText()
            asset = randAsset()
        } else if arc4random() % 10 > 2 {
            text = randomText()
            asset = nil
        } else {
            text = nil
            asset = randAsset()
        }
        
        let content = Content(
            createdAt: NSDate(),
            text: (text == nil) ? nil : "\(totalCount) :: \(text!)",
            assets: [asset].flatMap { $0 },
            author: User(
                id: 1000 + Int(arc4random() % 9999),
                name: randName(),
                previewImages: [randPreviewImage()]
            )
        )
        
        totalCount += 1
        receive(.appendContent([content]))
    }
    
    func debug_createStageEvents() {
        VTimerManager.addTimerManagerWithTimeInterval(
            10.0,
            target: self,
            selector: #selector(stageNext),
            userInfo: nil,
            repeats: true,
            toRunLoop: NSRunLoop.mainRunLoop(),
            withRunMode: NSRunLoopCommonModes
        )
        stageNext()
    }
    
    func stageNext() {
        stageCount = stageCount % sampleStageImageContents.count
        let random = sampleStageImageContents[stageCount]
        let contentType = ContentType(rawValue: random["type"]!)!
        let url = NSURL(string: random["url"]!)!
        
        let asset = ContentMediaAsset(
            contentType: contentType,
            url: url
        )!
        
        let content = Content(
            createdAt: NSDate(),
            text: randomText(),
            assets: [asset],
            author: User(
                id: 1000 + Int(arc4random() % 9999),
                name: randName(),
                previewImages: [randPreviewImage()]
            )
        )
        stage?.addContent(content)
        stageCount += 1
    }

}

private var stageCount = 0
private var totalCount = 0

private let sampleStageImageContents = [
    [
        "type": "image",
        "url": "http://sportsup365.com/wp-content/uploads/2015/12/usatsi_8903306.jpg"
    ],
    [
        "type": "image",
        "url": "http://www.koco.com/image/view/-/36170342/medRes/1/-/maxh/460/maxw/620/-/hwy60t/-/westbrook-jpg--1-.jpg"
    ],
    [
        "type": "image",
        "url": "http://cdn.fansided.com/wp-content/blogs.dir/20/files/2016/03/kevin-durant-lebron-james-nba-oklahoma-city-thunder-cleveland-cavaliers-850x549.jpg"
    ],
    [
        "type": "image",
        "url": "http://gazettereview.com/wp-content/uploads/2015/07/Paul-George.jpg"
    ],
    [
        "type": "image",
        "url": "http://download.gamezone.com/uploads/image/data/1203213/ogimage.img.jpg"
    ],
    [
        "type": "image",
        "url": "http://images.christianpost.com/full/88618/big-bang-theory.png"
    ],
    [
        "type": "image",
        "url": "https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcTOAIaM8CByCBip_Q4NeVR9JGjOBgUCV-BncDELPj_PO4yk3vQtTQ"
    ],
    [
        "type": "image",
        "url": "http://i.huffpost.com/gen/3005992/images/o-NBAFINALS-facebook.jpg"
    ],
    [
        "type": "image",
        "url": "https://www.tvnz.co.nz/content/dam/images/entertainment/shows/t/the-big-bang-theory/001_big_bang_theorycover.png.hashed.ac106368.747x420.jpg"
    ],
    [
        "type": "image",
        "url": "https://cdn0.vox-cdn.com/thumbor/Nj0YGHtKn9t6w77buNrODmhkSv8=/52x592:1732x1712/1310x873/cdn0.vox-cdn.com/uploads/chorus_image/image/49141793/GettyImages-514745962.0.jpg"
    ],
    [
        "type": "image",
        "url": "http://www.trbimg.com/img-570f3080/turbine/la-kobelast-la0037819123-20160413/1300/1300x731"
    ],
    [
        "type": "image",
        "url": "http://cavaliersnation.com/wp-content/uploads/2015/06/10443155_815244895226004_7294388762478468326_o-e1433368307903.jpg"
    ],
    [
        "type": "image",
        "url": "http://a.espncdn.com/photo/2015/0720/nba_g_shaq_pippen_b1_1296x729.jpg"
    ],
    [
        "type": "image",
        "url": "http://i.cdn.turner.com/drp/nba/rockets/sites/default/files/gettyimages-502208970.jpg"
    ],
    [
        "type": "image",
        "url": "http://images.performgroup.com/di/library/sporting_news/69/ff/stephen-curry-getty-ftr-111015_prho9atrmvpr1078za4ogxo1p.jpg?t=-237508088"
    ],
    [
        "type": "image",
        "url": "http://l2.yimg.com/bt/api/res/1.2/0uxmaqDK7Ug76SZJ5PCaLA--/YXBwaWQ9eW5ld3NfbGVnbztmaT1maWxsO2g9Mzc3O2lsPXBsYW5lO3B4b2ZmPTUwO3B5b2ZmPTA7cT03NTt3PTY3MA--/http://l.yimg.com/os/publish-images/sports/2015-04-15/fc8daba0-e396-11e4-80b5-a15058a85bfe_SC41515.jpg"
    ],
    [
        "type": "image",
        "url": "http://a.espncdn.com/combiner/i?img=/i/headshots/nba/players/full/1966.png&w=350&h=254"
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
