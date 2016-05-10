//
//  VideoPlayerCoordinator.swift
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

class VideoPlayerCoordinator: NSObject, VVideoPlayerDelegate, VideoToolbarDelegate {
    private var videoPlayer: VVideoPlayer = VVideoView()
    private var toolbar: VideoToolbarView = VideoToolbarView.viewFromNib()
    
    private var lastState: VideoState = .NotStarted
    private var state: VideoState = .NotStarted {
        didSet {
            lastState = oldValue
            toolbar.paused = state != .Playing
        }
    }
    private var content: VContent
    private var shouldLoop: Bool {
        guard let contentType = content.contentType() else {
            return false
        }
        return contentType == .gif
    }
    private var shouldMute: Bool {
        guard let contentType = content.contentType() else {
            return false
        }
        return contentType == .gif
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
        
        super.init()
        videoPlayer.delegate = self
        videoPlayer.view.backgroundColor = UIColor.clearColor()
        
        toolbar.delegate = self
    }
    
    func setupVideoPlayer(in superview: UIView) {
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
        guard let contentData = content.assets?.allObjects.first as? VContentData,
            let remoteSource = contentData.remoteSource,
            let contentURL = NSURL(string: remoteSource) else {
            return
        }
        let item = VVideoPlayerItem(URL: contentURL)
        item.muted = shouldMute
        item.remoteContentId = content.remoteID
        videoPlayer.setItem(item)
        videoPlayer.playFromStart()
        state = .Playing
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
        // if focus type detail
        videoPlayer.playFromStart()
        state = .Playing
    }
    
    func videoPlayerDidReachEnd(videoPlayer: VVideoPlayer) {
        // replay if necessary
        if  shouldLoop {
            videoPlayer.playFromStart()
        }
        else {
            videoPlayer.pause()
            state = .Ended
            //            delegate.videoPlaybackDidFinish()
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
        // updateQuartileTracking()
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
