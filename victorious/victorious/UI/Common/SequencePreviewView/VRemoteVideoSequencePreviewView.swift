//
//  VRemoteVideoSequencePreviewView.swift
//  victorious
//
//  Created by Patrick Lynch on 9/24/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

class VRemoteVideoSequencePreviewView : VVideoSequencePreviewView {
    
    override func createVideoPlayerWithFrame(frame: CGRect) -> VVideoPlayer {
        return VRemoteVideoPlayer()
    }
    
    override var focusType: VFocusType {
        didSet {
            if focusType != .None && self.videoPlayer.view.superview != self {
                self.videoPlayer.delegate = self
                self.addVideoPlayerView( self.videoPlayer.view )
            }
        }
    }
    
    override func willRemoveSubview(subview: UIView) {
        if subview == self.videoPlayer.view {
            
        }
    }
}