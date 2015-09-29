//
//  VContentPreviewViewReceiver.swift
//  victorious
//
//  Created by Patrick Lynch on 9/25/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Defines an object that can display a VSeqencePreviewView
@objc protocol VContentPreviewViewReceiver {
    
    /// Exposes a view that to which the preview view will be added as a subview during the transition
    func getTargetSuperview() -> UIView
    
    /// Setter for the preview view, where additional setup occurs
    func setPreviewView( previewView: VSequencePreviewView )
    
    /// Sets a reference to a video player (if there is one)
    func setVideoPlayer( videoPlayer: VVideoPlayer )
}