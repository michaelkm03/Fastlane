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
    var networkSource: NetworkSource? { get }
    
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
    
    func chatFeed(chatFeed: ChatFeed, didSelectMedia media: MediaAttachment) {
        // FUTURE: Show closeup/lightbox
    }
    
    // MARK: - ComposerDelegate
    
    func composer(composer: Composer, didSelectCreationFlowType creationFlowType: VCreationFlowType) {
        guard let attachmentType = creationFlowType.attachmentType else {
            assertionFailure("Not supported")
            return
        }
        
        let operation = SelectMediaAttachmentOperation(
            originViewController: originViewController,
            dependencyManager: dependencyManager,
            attachmentType: attachmentType,
            animated: true
        )
        operation.queue() { error, cancelled in
            if let result = operation.result {
                composer.setSelectedMediaAttachment(result.mediaAttachment, previewImage: result.previewImage)
            }
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
