//
//  ChatFeedDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Conformers will recieve messages related to interaction with chat feed content.
protocol ChatFeedDelegate: class {
    
    func chatFeed(chatFeed: ChatFeed, didSelectMessage message: VMessage)
    
    func chatFeed(chatFeed: ChatFeed, didSelectUser user: VUser)
    
    func chatFeed(chatFeed: ChatFeed, didSelectMedia media: VAsset)
}
