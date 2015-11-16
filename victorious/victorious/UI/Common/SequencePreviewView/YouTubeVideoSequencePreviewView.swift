//
//  YouTubeVideoSequencePreviewView.swift
//  victorious
//
//  Created by Patrick Lynch on 9/24/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

class YouTubeVideoSequencePreviewView : VVideoSequencePreviewView {
    
    class func remoteSourceName() -> String { return "youtube" }
    
    override var shouldAutoplay: Bool {
        // The current limitations of the YouTube web player make it impracticaly
        // to support auto play at this time, so we'll disable it
        return false
    }
    
    override var toolbarDisabled: Bool {
        // To avoid covering the YouTube logo in the player, we have to disable to toolbar
        // and use the default web-based one inside the player
        return false
    }
    
    override func createVideoPlayerWithFrame(frame: CGRect) -> VVideoPlayer {
        return YouTubeVideoPlayer()
    }
    
    override var focusType: VFocusType {
        didSet {
            if focusType != .Detail {
                self.videoPlayer.pauseAtStart()
                self.toolbar?.resetTime()
            }
        }
    }
}
