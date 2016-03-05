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
    
    var updateInRealtime: Bool = false {
        didSet {
            //Stop or start retrieving information from socket
        }
    }
    
    func addChatItems(chatItems: [ChatItem], animated: Bool = true) {
        
    }
    
    func deleteChatItems(chatItems: [ChatItem], animated: Bool = true) {
        
    }
    
    func toggleDetailDisplayOfChatItem(chatItem: ChatItem) {
        
    }
}
