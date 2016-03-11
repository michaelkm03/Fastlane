//
//  ComposerControllerDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Conformers will recieve messages when a composer's buttons are pressed and when
/// a composer changes its height.
protocol ComposerDelegate: class {
    
    func composer(composer: Composer, didSelectAttachmentTab: ComposerAttachmentTab)

    func composer(composer: Composer, didPressSendWithMedia: MediaAttachment, caption: String?)
    
    func composer(composer: Composer, didPressSendWithCaption: String)
    
    /// Called when the composer updates to a new height. The returned value represents
    /// the total height of the composer (including the keyboard) and should be less
    /// than the composer's maximumHeight.
    func composer(composer: Composer, didUpdateToHeight: CGFloat)
}