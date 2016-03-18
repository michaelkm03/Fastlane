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
protocol Forum: ChatFeedDelegate, ComposerDelegate, StageDelegate {
    
    // MARK: - Concrete dependencies
    
    var dependencyManager: VDependencyManager! { get }
    
    var originViewController: UIViewController { get }
    
    var creationFlowPresenter: VCreationFlowPresenter { get }
    
    // MARK: - Abstract subcomponents/dependencies
    
    var stage: Stage? { get }
    
    var composer: Composer? { get }
    
    var chatFeed: ChatFeed? { get }
}

/// The default implementation of the highest-level, abstract Forum business logic,
/// intended as a concise and flexible mini-architecture and defines the
/// most fundamental interation between parent and subcomponents.
extension Forum {
    
    // MARK: - ChatFeedDelegate
    
    func chatFeed(chatFeed: ChatFeed, didSelectUserWithUserID userID: Int) {
        ShowProfileOperation(originViewController: originViewController,
            dependencyManager: dependencyManager,
            userId: userID).queue()
    }
    
    func chatFeed(chatFeed: ChatFeed, didSelectMedia media: ForumMedia) {
        
    }
    
    // MARK: - ComposerDelegate
    
    func composer(composer: Composer, didSelectCreationType creationType: VCreationType) {
        creationFlowPresenter.shouldShowPublishScreenForFlowController = false
        creationFlowPresenter.presentWorkspaceOnViewController(originViewController, creationType: creationType)
    }
    
    func composer(composer: Composer, didConfirmWithMedia media: MediaAttachment?, caption: String?) {
        
    }
    
    func composer(composer: Composer, didUpdateToContentHeight height: CGFloat) {
        chatFeed?.setBottomInset(height ?? 0)
    }
    
    // MARK: - StageDelegate
    
    func stage(stage: Stage, didUpdateContentSize size: CGSize) {
        chatFeed?.setTopInset(size.height)
    }
    
    func stage(stage: Stage, didUpdateWithMedia media: ForumMedia) {
        
    }
    
    func stage(stage: Stage, didSelectMedia media: ForumMedia) {
        
    }
}
