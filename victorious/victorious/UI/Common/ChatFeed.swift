//
//  ChatFeed.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ChatFeed {
    
    weak var delegate: ChatFeedDelegate? { get set }
    
    /// Sets the inset around the container showing chat feed content.
    func setFeedEdgeInsets(insets: UIEdgeInsets, animated: Bool)
    
    /// Adds messages to the chat feed.
    func addMessages(messages: [VMessage], animated: Bool)
}
