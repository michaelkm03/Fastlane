//
//  MediaAttachmentGIFView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/31/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

// A media attachment view used for showing animated GIFs inline
class MediaAttachmentGIFView : MediaAttachmentView {
    
    let videoView = VVideoView()
    
    override var focusType: VFocusType {
        didSet {
            switch focusType {
            case .None:
                self.videoView.pauseFromStart()
            default:
                self.videoView.playFromStart()
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    private func sharedInit() {
        
        self.backgroundColor = UIColor.blackColor()
        
        self.addSubview(self.videoView)
        self.v_addFitToParentConstraintsToSubview(self.videoView)
    }
    
    private var autoplayURL: NSURL? {
        didSet {
            if let autoplayURL = autoplayURL {
                self.videoView.setItemURL(autoplayURL, loop: true, audioMuted: true)
                self.videoView.hidden = false
                if ( focusType != .None ) {
                    self.videoView.playFromStart()
                }
            }
        }
    }
    
    override var comment: VComment? {
        didSet {
            autoplayURL = comment?.properMediaURLGivenContentType()
        }
    }
    
    override var message: VMessage? {
        didSet {
            autoplayURL = message?.properMediaURLGivenContentType()
        }
    }
}