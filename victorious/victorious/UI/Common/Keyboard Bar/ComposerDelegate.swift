//
//  ComposerDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ComposerDelegate: class {
    
    func composerSelectedAttachmentTab(tab: ComposerAttachmentTab)
    
    func composerPressedSendWithMedia(caption: String?, media: MediaAttachment)
    
    func composerPressedSendWithCaption(caption: String)
}
