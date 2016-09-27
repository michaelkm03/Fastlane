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
    var chatFeedContext: DeeplinkContext { get }
    func creationFlowPresenter() -> VCreationFlowPresenter?
    
    // MARK: - Abstract subcomponents/dependencies
    
    var stage: Stage? { get }
    var composer: Composer? { get }
    var chatFeed: ChatFeed? { get }
    
    /// The abstract network layer used for feeding the Forum events and for sending events out.
    var forumNetworkSource: ForumNetworkSource? { get }
    
    // MARK: - Behaviors

    func setStageHeight(value: CGFloat)
}

/// The default implementation of the highest-level, abstract Forum business logic,
/// intended as a concise and flexible mini-architecture and defines the
/// most fundamental interaction between parent and subcomponents.
extension Forum {
    // MARK: - ChatFeedDelegate
    
    func chatFeed(chatFeed: ChatFeed, didSelectUserWithID userID: Int) {
        let router = Router(originViewController: originViewController, dependencyManager: dependencyManager)
        let destination = DeeplinkDestination(userID: userID)
        router.navigate(to: destination, from: chatFeedContext)
    }
    
    func chatFeed(chatFeed: ChatFeed, didSelect chatFeedContent: ChatFeedContent) {
        let router = Router(originViewController: originViewController, dependencyManager: dependencyManager)
        let destination = DeeplinkDestination(content: chatFeedContent.content)
        router.navigate(to: destination, from: chatFeedContext)
    }
    
    // MARK: - ComposerDelegate
    
    func composer(composer: Composer, didSelectCreationFlowType creationFlowType: VCreationFlowType) {
        creationFlowPresenter()?.presentWorkspaceOnViewController(originViewController, creationFlowType: creationFlowType)
    }

    func composer(composer: Composer, didUpdateContentHeight height: CGFloat) {
        chatFeed?.addedBottomInset = height
    }

    // MARK: - StageDelegate
    
    func stage(stage: Stage, wantsUpdateToContentHeight height: CGFloat) {
        setStageHeight(height)
        chatFeed?.addedTopInset = height
    }
}

private extension VCreationFlowType {
    var attachmentType: MediaAttachmentType? {
        switch self {
        case .GIF:
            return .GIF
        case .Image:
            return .Image
        default:
            return nil
        }
    }
}
