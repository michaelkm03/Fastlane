//
//  VCommentMediaView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VMessageMediaType {
    
    var attachmentType: MediaAttachmentType? {
        switch self {
        case .Image:
            return .Image
        case .GIF:
            return .GIF
        case .Video:
            return .Video
        default:
            return nil
        }
    }
}

extension VCommentMediaType {
    
    var attachmentType: MediaAttachmentType? {
        switch self {
        case .Image:
            return .Image
        case .GIF:
            return .GIF
        case .Video:
            return .Video
        case .Ballistic:
            return .Ballistic
        default:
            return nil
        }
    }
}

protocol MediaAttachmentViewType: NSObjectProtocol {
    func prepareForReuse()
    func setPreviewImageURL(url: NSURL)
    func setMediaURL(url: NSURL)
}

// TOOD: REmove any message or comment specific stuff from this class and out of this file

// A class cluster used for returning a view configured to display media
// attached to a comment or a message
class MediaAttachmentView: UIView, VFocusable, MediaAttachmentViewType {
    
    var comment: VComment?
    var message: VMessage?
    var dependencyManager: VDependencyManager?
    var respondToButton:((previewImage: UIImage?) -> Void)?
    
    // Factory method for returning correct concrete subclass with a comment
    class func mediaViewWithComment(comment: VComment) -> MediaAttachmentView? {
        guard let attachmentType = comment.commentMediaType().attachmentType else {
            return nil
        }
        let mediaAttachmentView = MediaAttachmentView.mediaViewForAttachment(attachmentType)
        if let unwrapped = mediaAttachmentView {
            unwrapped.comment = comment
            return unwrapped
        }
        return mediaAttachmentView
    }
    
    // Factory method for returning correct concrete subclass with a message
    class func mediaViewWithMessage(message: VMessage) -> MediaAttachmentView? {
        guard let attachmentType = message.messageMediaType().attachmentType else {
            return nil
        }
        let mediaAttachmentView = MediaAttachmentView.mediaViewForAttachment(attachmentType)
        if let unwrapped = mediaAttachmentView {
            unwrapped.message = message
            return unwrapped
        }
        return mediaAttachmentView
    }
    
    // Class method for returning a cell reuse identifier given a certain media type
    class func mediaViewForAttachment(type: MediaAttachmentType) -> MediaAttachmentView? {
        switch type {
        case .Image:
            return MediaAttachmentImageView()
        case .Video:
            return MediaAttachmentVideoView()
        case .GIF:
            return MediaAttachmentGIFView()
        case .Ballistic:
            return MediaAttachmentBallisticView()
        }
    }
    
    // Returns an cell reuse identifer for the proper concrete subclass
    class func reuseIdentifierForComment(comment: VComment) -> String {
        return comment.commentMediaType().attachmentType?.rawValue ?? "no_media"
    }
    
    // Returns an cell reuse identifer for the proper concrete subclass
    class func reuseIdentifierForMessage(message: VMessage) -> String {
        return message.messageMediaType().attachmentType?.rawValue ?? "no_media"
    }
    
    // MARK: - MediaAttachmentView
    
    func prepareForReuse() {
        // Subclasses can override
    }
    
    func setPreviewImageURL(url: NSURL) {
        // Subclasses can override
    }
    
    func setMediaURL(url: NSURL) {
        // Subclasses can override
    }
    
    // MARK: - VFocusable
    
    var focusType: VFocusType = .None
    
    func contentArea() -> CGRect {
        return CGRect.zero
    }
}
