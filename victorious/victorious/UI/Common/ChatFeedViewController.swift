//
//  ChatFeedViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ChatFeedViewController: UIViewController {
    
    private enum ChatItemDisplayState {
        case Expanded, Collapsed
    }
    
    private var chatItems = [(ChatItem, ChatItemDisplayState)]()
    
    /// The maximum number of lines shown when a chat item is
    /// in the "collapsed" state. Defaults to 0, allowing chat
    /// items to always show all content regardless of length.
    var maximumNumberOfChatItemLines = 0
    
    weak var delegate: ChatFeedViewControllerDelegate?
    
    /// When this is set to true, ellipses are shown underneath
    /// the current creator caption (if one exists). Defaults to false.
    var creatorIsTyping = false
    
    /// The space from the top to the top-most comment in the chat feed.
    var topInset: CGFloat = 0
    
    /// Adds a persistent, stylized caption at the top of the chat feed
    func addCreatorCaption(caption: String) {
        
    }
    
    /// Adds items into a private array of chat items managed by the chat feed.
    func addChatItems(chatItems: [ChatItem], animated: Bool = true) {
        
    }
    
    /// Deletes items from the private array of chat items managed by the chat feed.
    func deleteChatItems(chatItems: [ChatItem], animated: Bool = true) {
        
    }
    
    /// Toggles between the expanded and collapsed display states of a chat item.
    func toggleDetailDisplayOfChatItem(chatItem: ChatItem) {
        
    }
}
