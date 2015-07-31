//
//  VCommentMediaView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

// Views can implement this protocol to respond to
// a change in focus when scrolled in a table view
protocol Focus {
    var hasFocus: Bool { get set }
}

// Views can implement this protocol to properly prepare
// themselves for cell reuse
protocol Reuse {
    func prepareForReuse()
}

// A class cluster used for returning a view configured to display media
// attached to a comment or a message
class MediaAttachmentView : UIView, Focus, Reuse {
    
    var comment: VComment?
    var message: VMessage?
    var hasFocus = false
    var dependencyManager: VDependencyManager?
    var respondToButton:((previewImage: UIImage?) -> Void)?
    
    // Factory method for returning correct concrete subclass with a comment
    class func mediaViewWithComment(comment: VComment) -> MediaAttachmentView? {
        let attachmentType = MediaAttachmentType.attachmentType(comment)
        let mediaAttachmentView = MediaAttachmentView.mediaViewFactory(attachmentType)
        if let unwrapped = mediaAttachmentView {
            unwrapped.comment = comment
            return unwrapped
        }
        return mediaAttachmentView
    }
    
    // Factory method for returning correct concrete subclass with a message
    class func mediaViewWithMessage(message: VMessage) -> MediaAttachmentView? {
        let attachmentType = MediaAttachmentType.attachmentType(message)
        let mediaAttachmentView = MediaAttachmentView.mediaViewFactory(attachmentType)
        if let unwrapped = mediaAttachmentView {
            unwrapped.message = message
            return unwrapped
        }
        return mediaAttachmentView
    }
    
    // Class method for returning a cell reuse identifier given a certain media type
    class func mediaViewFactory(type: MediaAttachmentType) -> MediaAttachmentView? {
        var retVal: MediaAttachmentView?
        
        switch (type) {
        case .Image:
            retVal = MediaAttachmentImageView()
        case .Video:
            retVal = MediaAttachmentVideoView()
        case .GIF:
            retVal = MediaAttachmentGIFView()
        case .Ballistic:
            retVal = MediaAttachmentBallisticView()
        default:
            retVal = nil
        }
        
        return retVal
    }
    
    // Returns an cell reuse identifer for the proper concrete subclass
    class func reuseIdentifierForComment(comment: VComment) -> String {
        return MediaAttachmentType.attachmentType(comment).description
    }
    
    // Returns an cell reuse identifer for the proper concrete subclass
    class func reuseIdentifierForMessage(message: VMessage) -> String {
        return MediaAttachmentType.attachmentType(message).description
    }
    
    func prepareForReuse() {
        // Subclasses can override
    }
}
