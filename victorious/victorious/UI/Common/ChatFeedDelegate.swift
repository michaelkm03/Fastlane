//
//  ChatFeedDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ChatFeedDelegate: class {
    
    /// Called when a message is selected from the ChatFeed.
    func chatFeed(chatFeed: ChatFeed, didSelectMessage message: VMessage)
    
    /// Called when a message's poster is selected from the ChatFeed.
    func chatFeed(chatFeed: ChatFeed, didSelectUser user: VUser)
    
    /// Called when a message's media is selected from the ChatFeedController.
    func chatFeed(chatFeed: ChatFeed, didSelectMedia media: VAsset)
}
