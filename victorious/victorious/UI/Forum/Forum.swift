//
//  Forum.swift
//  victorious
//
//  Created by Patrick Lynch on 3/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Defines an object that requires these few properties in order to execute
/// the highest-level, abstract Forum business logic.  Plug and play :)
protocol Forum: ForumEventReceiver, ForumEventSender, ChatFeedDelegate, ComposerDelegate, StageDelegate {
    
    // MARK: - Concrete dependencies
    
    var dependencyManager: VDependencyManager! { get }
    
    var originViewController: UIViewController { get }
    
    // MARK: - Abstract subcomponents/dependencies
    
    var stage: Stage? { get }
    
    var composer: Composer? { get }
    
    var chatFeed: ChatFeed? { get }
}

/// The default implementation of the highest-level, abstract Forum business logic,
/// intended as a concise and flexible mini-architecture and defines the 
/// most fundamental interation between parent and subcomponents.
extension Forum {
    
    // MARK: - ForumEventReceiver
    
    var childEventReceivers: [ForumEventReceiver] {
        return [ stage as? ForumEventReceiver, chatFeed as? ForumEventReceiver ].flatMap { $0 }
    }
    
    // MARK: - ChatFeedDelegate
    
    func chatFeed(chatFeed: ChatFeed, didSelectUserWithUserID userID: Int) {
        ShowProfileOperation(originViewController: originViewController,
            dependencyManager: dependencyManager,
            userId: userID).queue()
    }
    
    func chatFeed(chatFeed: ChatFeed, didSelectMedia media: ForumMedia, withPreloadedImage image: UIImage, fromView referenceView: UIView) {
        ShowMediaLightboxOperation(originViewController: originViewController,
            preloadedImage: image,
            referenceView: referenceView).queue()
    }
    
    // MARK: - ComposerDelegate
    
    func composer(composer: Composer, didSelectAttachmentTab tab: ComposerAttachmentTab) {
  
    }
    
    func composer(composer: Composer, didConfirmWithMedia media: MediaAttachment?, caption: String?) {
        let event = ForumEvent(
            media: media,
            messageText: caption,
            date: NSDate()
        )
        sendEvent(event)
    }
    
    func composer(composer: Composer, didUpdateToContentHeight height: CGFloat) {
        chatFeed?.setEdgeInsets(UIEdgeInsets(top: stage?.contentHeight ?? 0, left: 0, bottom: height, right: 0))
    }
    
    // MARK: - StageDelegate
    
    func stage(stage: Stage, didUpdateWithMedia media: ForumMedia) {
  
    }
    
    func stage(stage: Stage, didSelectMedia media: ForumMedia) {
 
    }
}
