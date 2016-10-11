//
//  Composer.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

protocol Composer: class, ForumEventReceiver, ForumEventSender, ComposerAttachmentTabBarDelegate, TrayDelegate {
    
    /// The maximum height of the composer. Triggers a UI update if the composer
    /// could be updated to better represent its content inside a frame with the new height.
    var maximumTextInputHeight: CGFloat { get set }
    
    var creationFlowPresenter: VCreationFlowPresenter! { get }
    
    weak var delegate: ComposerDelegate? { get set }
    
    var topInset: CGFloat { get set }
    
    var dependencyManager: VDependencyManager! { get set }
    
    func dismissKeyboard(_ animated: Bool)
    
    func sendMessage(text: String, currentUser: UserModel)
    
    func sendMessage(asset: ContentMediaAsset, previewImage: UIImage, text: String?, currentUser: UserModel, isVIPOnly: Bool)
    
    func showKeyboard()
    
    func append(_ text: String)
}

extension Composer {
    func sendMessage(text: String, currentUser: UserModel) {
        let content = Content(author: currentUser, text: text)
        send(.sendContent(content))
    }
    
    func sendMessage(asset: ContentMediaAsset, previewImage: UIImage, text: String?, currentUser: UserModel, isVIPOnly: Bool) {
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
    /// Communicates when a navigation menu item is selected from the composer
    func didSelectNavigationMenuItem(_ navitionmenuItem: VNavigationMenuItem)

    func composer(_ composer: Composer, didSelectCreationFlowType creationFlowType: VCreationFlowType)
    
    /// Called when the composer updates to a new height. The returned value represents
    /// the total height of the composer content (including the keyboard) and can be more
    /// than the composer's maximumHeight.
    func composer(_ composer: Composer, didUpdateContentHeight height: CGFloat)
}
