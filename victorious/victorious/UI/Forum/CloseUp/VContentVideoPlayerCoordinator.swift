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

protocol ContentVideoPlayerCoordinatorDelegate: class {
    func coordinatorDidBecomeReady()
}

/// A coordinator that holds a VVideoView object adjusting for different types of VContent 
/// (currently supporting GIFs, videos, and youtube videos)
/// Sets up the video view and handles replay/buffering/scrubbing logic
class VContentVideoPlayerCoordinator: NSObject, VVideoPlayerDelegate, VideoToolbarDelegate {

    private struct Constants {
        static let toolbarHeight = CGFloat(41.0)
    }

    private var videoPlayer: VVideoPlayer = VVideoView()
    private var toolbar: VideoToolbarView = VideoToolbarView.viewFromNib()
    
    private var lastState: VideoState = .NotStarted
    private var state: VideoState = .NotStarted {
        didSet {
            lastState = oldValue
            toolbar.paused = state != .Playing
        }
    }
    private var content: ContentModel
    private var shouldLoop: Bool {
        return content.type == .gif
    }
    private var shouldMute: Bool {
        return content.type == .gif
    }
    
    weak var delegate: ContentVideoPlayerCoordinatorDelegate?
    
    init?(content: ContentModel) {
        self.content = content
        guard let asset = content.assetModels.first else {
            return nil
        }
        if content.type == .video && asset.videoSource == .youtube {
            videoPlayer = YouTubeVideoPlayer()
        }
        
        videoPlayer.view.backgroundColor = .clearColor()
        
        super.init()
        videoPlayer.delegate = self
        videoPlayer.view.backgroundColor = UIColor.clearColor()
        
        toolbar.delegate = self
    }
    
    func tearDown() {
        videoPlayer.view.removeFromSuperview()
        toolbar.removeFromSuperview()
    }
    
    func setupVideoPlayer(in superview: UIView) {
        superview.addSubview(videoPlayer.view)
    }
    
    func setupToolbar(in superview: UIView, initallyVisible visible: Bool) {
        superview.addSubview(toolbar)
        toolbar.v_addHeightConstraint(Constants.toolbarHeight)
        superview.v_addPinToLeadingTrailingToSubview(toolbar)
        superview.v_addPinToBottomToSubview(toolbar)
        
        if visible {
            toolbar.show()
        } else {
            toolbar.hide()
        }
    }
    
    func loadVideo() {
        guard let asset = content.assetModels.first else {
            assertionFailure("There were no assets for this piece of content.")
            return
        }
        
        var item: VVideoPlayerItem?
        
        if asset.videoSource == .youtube {
            item = VVideoPlayerItem(externalID: asset.resourceID)
        } else if let resourceURL = NSURL(string: asset.resourceID) {
            item = VVideoPlayerItem(URL: resourceURL)
        } else {
            return
        }
        
        if let item = item {
            item.muted = shouldMute
            item.useAspectFit = true
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
    
    func playVideo() {
        videoPlayer.play()
    }
    
    func pauseVideo() {
        videoPlayer.pause()
    }
    
    // MARK: - Layout
    
    func layout(in bounds: CGRect) {
        videoPlayer.view.frame = bounds
    }
    
    // MARK: - VVideoPlayerDelegate
    
    func videoPlayerDidBecomeReady(videoPlayer: VVideoPlayer) {
        videoPlayer.playFromStart()
        state = .Playing
        delegate?.coordinatorDidBecomeReady()
    }
    
    func videoPlayerItemIsReadyToPlay(videoPlayer: VVideoPlayer) {
        if let seekAheadTime = content.seekAheadTime where Int(videoPlayer.currentTimeSeconds) <= Int(seekAheadTime) {
            videoPlayer.seekToTimeSeconds(seekAheadTime)
        }
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
