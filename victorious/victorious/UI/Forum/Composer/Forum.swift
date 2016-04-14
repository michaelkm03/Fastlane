//
//  ForumNetworkingArchitecture.swift
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
    
    /// The abstract network layer used for feeding the Forum events and for sending events out.
    var networkSource: TemplateNetworkSource? { get }
    
    /**
        Prepare the network source and opens the connection.
     */
    func connectToNetworkSource()
    
    // MARK: - Behaviors

    func setStageHeight(value: CGFloat)
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
    
    func composer(composer: Composer, didSelectCreationFlowType creationFlowType: VCreationFlowType) {
        let presenter = VCreationFlowPresenter(dependencyManager: dependencyManager)
        presenter.shouldShowPublishScreenForFlowController = false
        presenter.presentWorkspaceOnViewController(originViewController, creationFlowType: creationFlowType)
    }
    
    func composer(composer: Composer, didConfirmWithMedia media: MediaAttachment, caption: String?) {
        if let event = ChatMessageOutbound(text: caption, contentUrl: media.url) {
            sendEvent(event)
        }
    }
    
    func composer(composer: Composer, didConfirmWithCaption caption: String) {
        if let event = ChatMessageOutbound(text: caption) {
            sendEvent(event)
        }
    }

    func composer(composer: Composer, didUpdateContentHeight height: CGFloat) {
        chatFeed?.setBottomInset(height)
    }
    
    // MARK: - StageDelegate
    
    func stage(stage: Stage, didUpdateContentHeight height: CGFloat) {
        setStageHeight(height)
        chatFeed?.setTopInset(height)
    }
    
    func stage(stage: Stage, didUpdateWithMedia media: Stageable) {
        
    }
    
    func stage(stage: Stage, didSelectMedia media: Stageable) {
        
    }
    
    // MARK: Network Source
    
    func connectToNetworkSource() {
        if let networkSource = networkSource where !networkSource.isConnected {
            // TODO: Replace with real token fetching logics when that endpoint is implemented.
            let newToken = "IOS\(arc4random_uniform(100))"
            networkSource.replaceToken(newToken)
            networkSource.connect()
        }
    }
}
