//
//  PreviewSequenceProvider.swift
//  victorious
//
//  Created by Patrick Lynch on 9/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// Defines an object that (1) can provide a view from its hiearchy to be handed off to another
/// context (such as the custom transition to `VNewContentViewController`),  and (2) can receive that
/// view when transitioning back from that context and insert it back into its original view hiearchy
@objc protocol VContentPreviewViewProvider {
    
    /// Exposes the preview view so that it may be plucked from its current view heiarchy
    /// and seamlessly added into content view
    func getPreviewView() -> VSequencePreviewView
    
    /// Replaces a preview view into the stream or marquee cell from which it came
    func restorePreviewView( previewView: VSequencePreviewView )
    
    /// Provides a view whose bounds represent the total contained area in a stream or marquee.
    func getContainerView() -> UIView
}

/// Defines an object that can display a VSeqencePreviewView
@objc protocol VContentPreviewViewReceiver {
    
    /// Exposes a view that to which the preview view will be added as a subview during the transition
    func getTargetSuperview() -> UIView
    
    /// Setter for the preview view, where additional setup occurs
    func setPreviewView( previewView: VSequencePreviewView )
    
    /// Sets a reference to a video player (if there is one)
    func setVideoPlayer( videoPlayer: VVideoPlayer )
}