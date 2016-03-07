//
//  ComposerViewControllerDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ComposerViewControllerDelegate: class {
    
    /// Called when an attachment tab is pressed.
    func composer(composer: ComposerViewController, selectedAttachmentTab: ComposerViewControllerAttachmentTab)

    /// Called when send is pressed with media present in the composer.
    func composer(composer: ComposerViewController, pressedSendWithMedia: MediaAttachment, caption: String?)
    
    /// Called when send is pressed without media present in the composer.
    func composer(composer: ComposerViewController, pressedSendWithCaption: String)
    
    /// Called when the composer updates to a new height. The returned value represents
    /// the total height of the composer (including the keyboard) and should be less
    /// than the composer's maximumHeight. Optional.
    func composer(composer: ComposerViewController, didUpdateToHeight: CGFloat)
}

extension ComposerViewControllerDelegate {
    
    func composer(composer: ComposerViewController, didUpdateToHeight: CGFloat) {}
}
