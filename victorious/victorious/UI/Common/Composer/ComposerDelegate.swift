//
//  ComposerDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ComposerDelegate: class {
    
    ///This method will be called when an attachment tab is pressed
    func composerSelectedAttachmentTab(tab: ComposerAttachmentTab)

    ///Called when send is pressed with media present in the composer
    func composerPressedSendWithMedia(caption: String?, media: MediaAttachment)
    
    ///Called when send is pressed without media present in the composer
    func composerPressedSendWithCaption(caption: String)
    
    ///Called when the composer updates to a new height. The returned value represets
    ///the total height of the composer (including the keyboard) and should be less
    ///than the composer's maximumHeight.
    func composerWillUpdateToHeight(height: CGFloat)
}

extension ComposerDelegate {
    
    func composerWillExpandToHeight(height: CGFloat) {}
}
