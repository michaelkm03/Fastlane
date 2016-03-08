//
//  ChatFeedViewControllerDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ChatFeedViewControllerDelegate: class {
    
    /// Called when a message is selected from the ChatFeedViewController.
    func chatFeed(chatFeedViewController: ChatFeedViewController, selectedMessage message: VMessage)
    
    /// Called when a message's poster is selected from the ChatFeedViewController.
    func chatFeed(chatFeedViewController: ChatFeedViewController, selectedUser user: VUser)
    
    /// Called when a message's media is selected from the ChatFeedViewController.
    func chatFeed(chatFeedViewController: ChatFeedViewController, selectedMedia media: VAsset)
}
