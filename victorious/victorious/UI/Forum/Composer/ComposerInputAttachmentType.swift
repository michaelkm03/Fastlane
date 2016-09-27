//
//  ComposerInputAttachmentType.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Describes attachment types that do not present creation flows but can be returned as menu items in the composer.
enum ComposerInputAttachmentType: String {
    case Hashtag = "Add Hashtag"
    case StickerTray = "Add Sticker from Tray"
    case GIFTray = "Add GIF from Tray"
    case GIFFlow = "Create GIF"
}
