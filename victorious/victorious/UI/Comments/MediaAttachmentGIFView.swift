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
    
    override var hasFocus: Bool {
        didSet {
            hasFocus ? self.videoView.play() : self.videoView.pause()
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
    
    override var comment: VComment? {
        didSet {
            if let autoplayURL = comment?.properMediaURLGivenContentType() {
                self.videoView.setItemURL(autoplayURL, loop: true, audioMuted: true)
                self.videoView.hidden = false
            }
        }
    }
}