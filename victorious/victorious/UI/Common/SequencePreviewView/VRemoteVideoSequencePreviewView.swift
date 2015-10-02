//
//  VRemoteVideoSequencePreviewView.swift
//  victorious
//
//  Created by Patrick Lynch on 9/24/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

class VRemoteVideoSequencePreviewView : VVideoSequencePreviewView {
    
    override var likeButtonDisabled: Bool {
        // The like button covers the YouTube logo in the player,
        // so we have to disable it in this sequence preview view type
        return true
    }
    
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
        return VRemoteVideoPlayer()
    }
}
