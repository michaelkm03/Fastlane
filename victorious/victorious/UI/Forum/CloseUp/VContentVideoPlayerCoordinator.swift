//
//  VContentVideoPlayerCoordinator.swift
//  victorious
//
//  Created by Vincent Ho on 4/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

enum VideoState {
    case Buffering,
    Ended,
    NotStarted,
    Paused,
    Playing,
    Scrubbing
}

/// A coordinator that holds a VVideoView object adjusting for different types of VContent 
/// (currently supporting GIFs, videos, and youtube videos)
/// Sets up the video view and handles replay/buffering/scrubbing logic
class VContentVideoPlayerCoordinator: NSObject, VVideoPlayerDelegate, VideoToolbarDelegate {
    private var videoPlayer: VVideoPlayer = VVideoView()
    private var toolbar: VideoToolbarView = VideoToolbarView.viewFromNib()
    private var previewView: UIImageView /// Preview view to show the thumbnail image as the video loads
    
    private var lastState: VideoState = .NotStarted
    private var state: VideoState = .NotStarted {
        didSet {
            lastState = oldValue
            toolbar.paused = state != .Playing
        }
    }
    private var content: VContent
    private var shouldLoop: Bool {
        return content.contentType() == .gif
    }
    private var shouldMute: Bool {
        return content.contentType() == .gif
    }
    
    init?(content: VContent) {
        self.content = content
        guard let firstAsset = content.assets?.allObjects.first as? VContentData else {
            return nil
        }
        if let contentType = content.contentType()
            where contentType == .video && firstAsset.source == "youtube" {
            videoPlayer = YouTubeVideoPlayer()
        }
        
        videoPlayer.view.backgroundColor = .clearColor()
        
        previewView = UIImageView()
        let minWidth = UIScreen.mainScreen().bounds.size.width
        
        if let preview = content.previewImageWithMinimumWidth(minWidth),
            let remoteSource = preview.imageURL,
            let remoteURL = NSURL(string: remoteSource) {
            previewView.sd_setImageWithURL(remoteURL)
        }
        super.init()
        videoPlayer.delegate = self
        videoPlayer.view.backgroundColor = UIColor.clearColor()
        
        toolbar.delegate = self
    }
    
    func setupVideoPlayer(in superview: UIView) {
        superview.addSubview(previewView)
        superview.v_addFitToParentConstraintsToSubview(previewView)
        superview.addSubview(videoPlayer.view)
        superview.v_addFitToParentConstraintsToSubview(videoPlayer.view)
    }
    
    func setupToolbar(in superview: UIView, initallyVisible visible: Bool) {
        superview.addSubview(toolbar)
        toolbar.v_addHeightConstraint(41.0)
        superview.v_addPinToLeadingTrailingToSubview(toolbar)
        superview.v_addPinToBottomToSubview(toolbar)
        if visible {
            toolbar.show()
        }
        else {
            toolbar.hide()
        }
    }
    
    func loadVideo() {
        guard let contentData = content.assets?.allObjects.first as? VContentData else {
            assertionFailure("There were no assets for this piece of content.")
            return
        }
        
        var item: VVideoPlayerItem?
        if let remoteSource = contentData.remoteSource,
            let contentURL = NSURL(string: remoteSource) {
            item = VVideoPlayerItem(URL: contentURL)
        }
        if let externalID = contentData.externalID {
            item = VVideoPlayerItem(externalID: externalID)
        }
        if let item = item {
            item.muted = shouldMute
            videoPlayer.setItem(item)
            videoPlayer.playFromStart()
            state = .Playing
            return
        }
    }
    
    func toggleToolbarVisibility(animated: Bool) {
        if !toolbar.isVisible {
            toolbar.show(animated: animated)
        }
        else {
            toolbar.hide(animated: animated)
        }
    }
    
    // MARK: - VVideoPlayerDelegate
    
    func videoPlayerDidBecomeReady(videoPlayer: VVideoPlayer) {
        videoPlayer.playFromStart()
        state = .Playing
        previewView.hidden = true
    }
    
    func videoPlayerDidReachEnd(videoPlayer: VVideoPlayer) {
        videoPlayer.pause()
        // Replay the video if necessary
        if  shouldLoop {
            videoPlayer.playFromStart()
        }
        else {
            state = .Ended
        }
    }
    
    func videoPlayerDidStartBuffering(videoPlayer: VVideoPlayer) {
        if state != .Scrubbing && state != .Paused {
            state = .Buffering
        }
    }
    
    func videoPlayerDidStopBuffering(videoPlayer: VVideoPlayer) {
        if state == .Buffering {
            videoPlayer.play()
            state = .Playing
        }
    }
    
    func videoPlayer(videoPlayer: VVideoPlayer, didPlayToTime time: Float64) {
        toolbar.setCurrentTime(videoPlayer.currentTimeSeconds, duration: videoPlayer.durationSeconds)
    }
    
    func videoPlayerDidPlay(videoPlayer: VVideoPlayer) {
        state = .Playing;
    }
    
    func videoPlayerDidPause(videoPlayer: VVideoPlayer) {
        if state != .NotStarted && state != .Scrubbing {
            state = .Paused
        }
    }
    
    // MARK: - VideoToolbarDelegate
    
    func videoToolbarDidPlay(videoToolbar: VideoToolbarView) {
        videoPlayer.play()
    }
    
    func videoToolbarDidPause(videoToolbar: VideoToolbarView) {
        videoPlayer.pause()
    }
    
    func videoToolbar(videoToolbar: VideoToolbarView, didScrubToLocation location: Float) {
        let timeSeconds: NSTimeInterval = Double(location) * videoPlayer.durationSeconds
        videoPlayer.seekToTimeSeconds(timeSeconds)
    }
    
    func videoToolbar(videoToolbar: VideoToolbarView, didEndScrubbingToLocation location: Float) {
        if lastState == .Playing {
            videoPlayer.play()
        }
        else {
            videoPlayer.pause()
        }
    }
    
    func videoToolbar(videoToolbar: VideoToolbarView, didStartScrubbingToLocation location: Float) {
        state = .Scrubbing
        videoPlayer.pause()
    }
}
