//
//  VCommentMediaView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

// Views can implement this protocol to properly prepare
// themselves for cell reuse
protocol Reuse {
    func prepareForReuse()
}

// A class cluster used for returning a view configured to display media
// attached to a comment or a message
class MediaAttachmentView : UIView, VFocusable, Reuse {
    
    var comment: VComment?
    var message: VMessage?
    var dependencyManager: VDependencyManager?
    var respondToButton:((previewImage: UIImage?) -> Void)?
    
    // Factory method for returning correct concrete subclass with a comment
    class func mediaViewWithComment(comment: VComment) -> MediaAttachmentView? {
        let attachmentType = MediaAttachmentType.attachmentType(comment)
        let mediaAttachmentView = MediaAttachmentView.mediaViewForAttachment(attachmentType)
        if let unwrapped = mediaAttachmentView {
            unwrapped.comment = comment
            return unwrapped
        }
        return mediaAttachmentView
    }
    
    // Factory method for returning correct concrete subclass with a message
    class func mediaViewWithMessage(message: VMessage) -> MediaAttachmentView? {
        let attachmentType = MediaAttachmentType.attachmentType(message)
        let mediaAttachmentView = MediaAttachmentView.mediaViewForAttachment(attachmentType)
        if let unwrapped = mediaAttachmentView {
            unwrapped.message = message
            return unwrapped
        }
        return mediaAttachmentView
    }
    
    // Class method for returning a cell reuse identifier given a certain media type
    class func mediaViewForAttachment(type: MediaAttachmentType) -> MediaAttachmentView? {
        var mediaAttachmentView: MediaAttachmentView?
        
        switch (type) {
        case .Image:
            mediaAttachmentView = MediaAttachmentImageView()
        case .Video:
            mediaAttachmentView = MediaAttachmentVideoView()
        case .GIF:
            mediaAttachmentView = MediaAttachmentGIFView()
        case .Ballistic:
            mediaAttachmentView = MediaAttachmentBallisticView()
        default:
            mediaAttachmentView = nil
        }
        
        return mediaAttachmentView
    }
    
    // Returns an cell reuse identifer for the proper concrete subclass
    class func reuseIdentifierForComment(comment: VComment) -> String {
        return MediaAttachmentType.attachmentType(comment).rawValue
    }
    
    // Returns an cell reuse identifer for the proper concrete subclass
    class func reuseIdentifierForMessage(message: VMessage) -> String {
        return MediaAttachmentType.attachmentType(message).rawValue
    }
    
    func prepareForReuse() {
        // Subclasses can override
    }
    
    // MARK: - VFocusable
    
    var focusType: VFocusType = .None
    
    func contentArea() -> CGRect {
        return CGRect.zero
    }
}

private extension MediaAttachmentType {
    
    static func attachmentType(comment: VComment) -> MediaAttachmentType {
        let commentMediaType = comment.commentMediaType()
        switch (commentMediaType) {
        case .Image:
            return .Image
        case .Video:
            return .Video
        case .GIF:
            return .GIF
        case .Ballistic:
            return .Ballistic
        default:
            return .NoMedia
        }
    }
    
    static func attachmentType(message: VMessage) -> MediaAttachmentType {
        let messageMediaType = message.messageMediaType()
        switch (messageMediaType) {
        case .Image:
            return .Image
        case .GIF:
            return .GIF
        case .Video:
            return .Video
        default:
            return .NoMedia
        }
    }
}
