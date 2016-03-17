//
//  ChatFeed.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ChatFeed: class, ForumEventReceiver {
    
    weak var delegate: ChatFeedDelegate? { get set }
    
    var dependencyManager: VDependencyManager! { get set }
    
    func setBottomInset(value: CGFloat)
    
    func setTopInset(value: CGFloat)
}

protocol ChatFeedDelegate: class {
    
    func chatFeed(chatFeed: ChatFeed, didSelectUserWithUserID userID: Int)
    
    func chatFeed(chatFeed: ChatFeed, didSelectMedia media: ForumMedia, withPreloadedImage image: UIImage, fromView referenceView: UIView)
}
