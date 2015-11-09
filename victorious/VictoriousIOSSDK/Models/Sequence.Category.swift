//
//  Sequence.Category.swift
//  victorious
//
//  Created by Patrick Lynch on 11/6/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

extension Sequence {
    public enum Category: String {
        case OwnerPoll          = "owner_poll"
        case OwnerText          = "owner_text"
        case OwnerTextRepost    = "owner_text_repost"
        case OwnerImage         = "owner_image"
        case OwnerImageRepost   = "owner_image_repost"
        case OwnerImageQuote    = "owner_image_secret"
        case OwnerImageMeme     = "owner_image_meme"
        case OwnerVideo         = "owner_video"
        case OwnerVideoRemix    = "owner_video_remix"
        case OwnerVideoRepost   = "owner_video_repost"
        case OwnerMemeRepost    = "owner_meme_repost"
        case OwnerQuoteRepost   = "owner_secret_repost"
        
        case UGCPoll            = "ugc_poll"
        case UGCText            = "ugc_text"
        case UGCTextRepost      = "ugc_text_repost"
        case UGCImage           = "ugc_image"
        case UGCImageRepost     = "ugc_image_repost"
        case UGCImageQuote      = "ugc_image_secret"
        case UGCImageMeme       = "ugc_image_meme"
        case UGCVideo           = "ugc_video"
        case UGCVideoRemix      = "ugc_video_remix"
        case UGCVideoRepost     = "ugc_video_repost"
        case UGCMemeRepost      = "ugc_meme_repost"
        case UGCQuoteRepost     = "ugc_secret_repost"
    }
}