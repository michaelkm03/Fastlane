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
        case Detail, Collapsed
    }
    
    private var chatItems = [(ChatItem, ChatItemDisplayState)]()
    
    var updateInRealtime: Bool = false {
        didSet {
            //Stop or start retrieving information from socket
        }
    }
    
    func addChatItems(chatItems: [ChatItem]) {
        
    }
    
    func toggleDetailDisplayOfChatItem(chatItem: ChatItem) {
        
    }
}
