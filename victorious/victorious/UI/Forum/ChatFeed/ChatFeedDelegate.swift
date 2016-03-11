//
//  ChatFeedDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ChatFeedDelegate: class {
    
    func chatFeed(chatFeed: ChatFeed, didSelectUserWithUserID userID: Int)
    
    func chatFeed(chatFeed: ChatFeed, didSelectMedia media: ForumMedia, withPreloadedImage image: UIImage, fromView referenceView: UIView)
}
