//
//  ChatFeedControllerDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ChatFeedControllerDelegate {
    
    func chatFeed(chatFeed: ChatFeedController, selectedChatItem chatItem: VStreamItem)
    
    func chatFeed(chatFeed: ChatFeedController, selectedUser user: VUser)
    
    func chatFeed(chatFeed: ChatFeedController, selectedMedia media: VAsset)
}
