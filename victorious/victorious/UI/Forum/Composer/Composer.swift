//
//  Composer.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

protocol Composer: class, ForumEventReceiver, ForumEventSender, ComposerAttachmentTabBarDelegate {
    
    /// The maximum height of the composer. Triggers a UI update if the composer
    /// could be updated to better represent its content inside a frame with the new height.
    var maximumTextInputHeight: CGFloat { get set }
    
    var creationFlowPresenter: VCreationFlowPresenter! { get }
    
    weak var delegate: ComposerDelegate? { get set }
    
    var dependencyManager: VDependencyManager! { get set }
    
    func dismissKeyboard(animated: Bool)
    
    func sendMessage(text text: String, currentUser: UserModel)
    
    func sendMessage(asset asset: ContentMediaAsset, previewImage: UIImage, text: String?, currentUser: UserModel, isVIPOnly: Bool)
    
    func setComposerVisible(visible: Bool, animated: Bool)
}

extension Composer {
    
    func sendMessage(text text: String, currentUser: UserModel) {
        let content = Content(author: currentUser, text: text)
        send(.sendContent(content))
    }
    
    func sendMessage(asset asset: ContentMediaAsset, previewImage: UIImage, text: String?, currentUser: UserModel, isVIPOnly: Bool) {
        let previewImageAsset = ImageAsset(image: previewImage)
        let content = Content(
            author: currentUser,
            type: asset.contentType,
            text: text,
            assets: [asset],
            previewImages: [previewImageAsset],
            isVIPOnly: isVIPOnly
        )
        send(.sendContent(content))
    }
}

/// Conformers will recieve messages when a composer's buttons are pressed and when
/// a composer changes its height.
protocol ComposerDelegate: class, ForumEventSender {
    
    func composer(composer: Composer, didSelectCreationFlowType creationFlowType: VCreationFlowType)
    
    /// Called when the composer updates to a new height. The returned value represents
    /// the total height of the composer content (including the keyboard) and can be more
    /// than the composer's maximumHeight.
    func composer(composer: Composer, didUpdateContentHeight height: CGFloat)
}
