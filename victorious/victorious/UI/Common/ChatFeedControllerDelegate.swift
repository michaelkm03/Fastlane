//
//  ChatFeedControllerDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ChatFeedControllerDelegate: class {
    
    /// Called when a message is selected from the ChatFeedController.
    func chatFeedController(chatFeedController: ChatFeedController, didSelectMessage message: VMessage)
    
    /// Called when a message's poster is selected from the ChatFeedController.
    func chatFeedController(chatFeedController: ChatFeedController, didSelectUser user: VUser)
    
    /// Called when a message's media is selected from the ChatFeedController.
    func chatFeedController(chatFeedController: ChatFeedController, didSelectMedia media: VAsset)
}
