//
//  ChatFeedViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ChatFeedViewController: UIViewController {
    
    private enum MessageDisplayState {
        case Expanded, Collapsed
    }
    
    private var messages = [(VMessage, MessageDisplayState)]()
    
    /// The maximum number of lines shown when a message is
    /// in the "collapsed" state. Defaults to 0, allowing messages
    /// to always show all content regardless of length.
    private let maximumMessageLines = 0
    
    weak var delegate: ChatFeedViewControllerDelegate?
    
    /// Sets the inset around the container showing chat feed content.
    func setFeedEdgeInsets(insets: UIEdgeInsets, animated: Bool = true) {
        
    }
    
    /// When typing is true, ellipses are shown underneath the
    /// current pinned message (if one exists). Defaults to false.
    func setHostIsTyping(typing: Bool, animated: Bool = true) {
        
    }
    
    /// Adds a persistent, stylized message at the top of the chat feed.
    func addPinnedMessage(message: VMessage, animated: Bool = true) {
        
    }
    
    /// Adds messages to the chat feed.
    func addMessages(messages: [VMessage], animated: Bool = true) {
        
    }
    
    /// Deletes messages posted by the provided user.
    func blockMessagesFromUser(user: VUser, animated: Bool = true) {
        
    }
    
    /// Toggles between the expanded and collapsed display states of a message.
    func toggleDetailDisplayOfMessage(message: VMessage, animated: Bool = true) {
        
    }
}
