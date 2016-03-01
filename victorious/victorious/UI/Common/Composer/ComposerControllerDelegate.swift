//
//  ComposerControllerDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ComposerControllerDelegate: class {
    
    /// This method will be called when an attachment tab is pressed
    func composer(composer: ComposerController, selectedAttachmentTab: ComposerControllerAttachmentTab)

    /// Called when send is pressed with media present in the composer
    func composer(composer: ComposerController, pressedSendWithMedia: MediaAttachment, caption: String?)
    
    /// Called when send is pressed without media present in the composer
    func composer(composer: ComposerController, pressedSendWithCaption: String)
    
    /// Called when the composer updates to a new height. The returned value represets
    /// the total height of the composer (including the keyboard) and should be less
    /// than the composer's maximumHeight.
    func composer(composer: ComposerController, didUpdateToHeight: CGFloat)
}

extension ComposerControllerDelegate {
    
    func composer(composer: ComposerController, didUpdateToHeight: CGFloat) {}
}
