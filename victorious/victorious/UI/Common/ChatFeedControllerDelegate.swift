//
//  ChatFeedControllerDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ChatFeedControllerDelegate {
    
    /// Called when a chat item is selected from the ChatController
    func chatFeed(chatFeed: ChatFeedController, selectedChatItem chatItem: ChatItem)
    
    /// Called when a chat item's poster is selected from the ChatController
    func chatFeed(chatFeed: ChatFeedController, selectedUser user: VUser)
    
    /// Called when a chat item's media is selected from the ChatController
    func chatFeed(chatFeed: ChatFeedController, selectedMedia media: VAsset)
}
