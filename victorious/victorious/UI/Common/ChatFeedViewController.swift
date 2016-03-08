//
//  ChatFeedViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ChatFeedViewController: UIViewController, ChatFeedController {
    
    private enum MessageDisplayState {
        case Expanded, Collapsed
    }
    
    private var messages = [VMessage: MessageDisplayState]()
    
    /// The maximum number of lines shown when a message is
    /// in the "collapsed" state. Defaults to 0, allowing messages
    /// to always show all content regardless of length.
    private let maximumMessageLines = 0
    
    
    //MARK: - ChatFeedController
    
    weak var delegate: ChatFeedViewControllerDelegate?
    
    func setFeedEdgeInsets(insets: UIEdgeInsets, animated: Bool = true) {
        
    }
    
    func setHostIsTyping(typing: Bool, animated: Bool = true) {
        
    }
    
    func addPinnedMessage(message: VMessage, animated: Bool = true) {
        
    }
    
    func addMessages(messages: [VMessage], animated: Bool = true) {
        
    }
    
    func blockMessagesFromUser(user: VUser, animated: Bool = true) {
        
    }
    
    func toggleDetailDisplayOfMessage(message: VMessage, animated: Bool = true) {
        
    }
}
