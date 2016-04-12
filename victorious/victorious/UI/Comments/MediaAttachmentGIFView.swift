//
//  MediaAttachmentGIFView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/31/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

// A media attachment view used for showing animated GIFs inline
class MediaAttachmentGIFView: MediaAttachmentView {
    
    let videoPlayer: VVideoPlayer = VVideoView()
    
    override var focusType: VFocusType {
        didSet {
            switch focusType {
            case .None:
                self.videoPlayer.pauseAtStart()
            default:
                self.videoPlayer.playFromStart()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    private func sharedInit() {
        
        self.backgroundColor = UIColor.blackColor()
        
        self.addSubview(self.videoPlayer.view)
        self.v_addFitToParentConstraintsToSubview(self.videoPlayer.view)
    }
    
    private var autoplayURL: NSURL? {
        didSet {
            if let autoplayURL = autoplayURL {
                let videoPlayerItem = VVideoPlayerItem(URL: autoplayURL)
                videoPlayerItem.loop = true
                videoPlayerItem.muted = true
                self.videoPlayer.setItem( videoPlayerItem )
                self.videoPlayer.view.hidden = false
                if focusType != .None {
                    self.videoPlayer.playFromStart()
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
