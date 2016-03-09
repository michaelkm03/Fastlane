//
//  ComposerControllerDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ComposerDelegate: class {
    
    /// Called when an attachment tab is pressed.
    func composer(composer: Composer, didSelectAttachmentTab: ComposerAttachmentTab)

    /// Called when send is pressed with media present in the composer.
    func composer(composer: Composer, didPressSendWithMedia: MediaAttachment, caption: String?)
    
    /// Called when send is pressed without media present in the composer.
    func composer(composer: Composer, didPressSendWithCaption: String)
    
    /// Called when the composer updates to a new height. The returned value represents
    /// the total height of the composer (including the keyboard) and should be less
    /// than the composer's maximumHeight. Optional.
    func composer(composer: Composer, didUpdateToHeight: CGFloat)
}

extension ComposerDelegate {
    
    func composer(composer: Composer, didUpdateToHeight: CGFloat) {}
}
