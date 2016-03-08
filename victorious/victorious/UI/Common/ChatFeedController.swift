//
//  ChatFeedController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ChatFeedController {
    
    weak var delegate: ChatFeedControllerDelegate? { get set }
    
    /// Sets the inset around the container showing chat feed content.
    func setFeedEdgeInsets(insets: UIEdgeInsets, animated: Bool)
    
    /// When typing is true, ellipses are shown underneath the
    /// current pinned message (if one exists). Defaults to false.
    func setHostIsTyping(typing: Bool, animated: Bool)
    
    /// Adds a persistent, stylized message at the top of the chat feed.
    func addPinnedMessage(message: VMessage, animated: Bool)
    
    /// Adds messages to the chat feed.
    func addMessages(messages: [VMessage], animated: Bool)
    
    /// Deletes messages posted by the provided user.
    func blockMessagesFromUser(user: VUser, animated: Bool)
    
    /// Toggles between the expanded and collapsed display states of a message.
    func toggleDetailDisplayOfMessage(message: VMessage, animated: Bool)
}
