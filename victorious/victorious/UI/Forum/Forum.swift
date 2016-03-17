//
//  Forum.swift
//  victorious
//
//  Created by Patrick Lynch on 3/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol Forum: ChatFeedDelegate, ComposerDelegate, StageDelegate {

    var dependencyManager: VDependencyManager! { get }
    
    var originViewController: UIViewController { get }
    
    var stage: Stage? { get }
    
    var composer: Composer? { get }
    
    var chatFeed: ChatFeed? { get }
}

extension Forum {
    
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
  
    }
    
    // MARK: - StageDelegate
    
    func stage(stage: Stage, didUpdateWithMedia media: ForumMedia) {
  
    }
    
    func stage(stage: Stage, didSelectMedia media: ForumMedia) {
 
    }
}
