//
//  ForumNetworkingArchitecture.swift
//  victorious
//
//  Created by Patrick Lynch on 3/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

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

    func setStageHeight(_ value: CGFloat)
}

/// The default implementation of the highest-level, abstract Forum business logic,
/// intended as a concise and flexible mini-architecture and defines the
/// most fundamental interaction between parent and subcomponents.
extension Forum {
    // MARK: - ChatFeedDelegate
    
    func chatFeed(_ chatFeed: ChatFeed, didSelectUserWithID userID: User.ID) {
        let router = Router(originViewController: originViewController, dependencyManager: dependencyManager)
        let destination = DeeplinkDestination(userID: userID)
        router.navigate(to: destination, from: chatFeedContext)
    }
    
    func chatFeed(_ chatFeed: ChatFeed, didSelect chatFeedContent: ChatFeedContent) {
        let router = Router(originViewController: originViewController, dependencyManager: dependencyManager)
        let destination = DeeplinkDestination(content: chatFeedContent.content)

        router.navigate(to: destination, from: chatFeedContext)
    }
    
    // MARK: - ComposerDelegate
    
    func composer(_ composer: Composer, didSelectCreationFlowType creationFlowType: VCreationFlowType) {
        creationFlowPresenter()?.presentWorkspace(on: originViewController, creationFlowType: creationFlowType)
    }

    func composer(_ composer: Composer, didUpdateContentHeight height: CGFloat) {
        chatFeed?.addedBottomInset = height
    }

    // MARK: - StageDelegate
    
    func stage(_ stage: Stage, wantsUpdateToContentHeight height: CGFloat) {
        setStageHeight(height)
        chatFeed?.addedTopInset = height
    }
}

private extension VCreationFlowType {
    var attachmentType: MediaAttachmentType? {
        switch self {
        case .GIF:
            return .GIF
        case .image:
            return .Image
        default:
            return nil
        }
    }
}
