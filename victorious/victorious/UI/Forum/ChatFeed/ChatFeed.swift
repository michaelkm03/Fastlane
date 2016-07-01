//
//  ChatFeed.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ChatFeed: class, ForumEventReceiver, ForumEventSender {
    
    weak var delegate: ChatFeedDelegate? { get set }
    
    weak var nextSender: ForumEventSender? { get set }
    
    var dependencyManager: VDependencyManager! { get set }
        
    func setTopInset(value: CGFloat)
    
    func setBottomInset(value: CGFloat)
}

protocol ChatFeedDelegate: class {
    
    func chatFeed(chatFeed: ChatFeed, didSelectUserWithUserID userID: Int)
    
    func chatFeed(chatFeed: ChatFeed, didSelectContent content: ContentModel)
}
