//
//  MediaAttachmentType.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Describes the different types of media that can be attached to a comment or a direct message.
public enum MediaAttachmentType: String {
    case Image = "image"
    case Video = "video"
    case GIF = "gif"
    case VoteType = "voteType"
}
