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

    private var lastState: VideoState = .NotStarted
    private var state: VideoState = .NotStarted {
        didSet {
            lastState = oldValue
            toolbar.paused = state != .Playing
        }
    }
    private var content: ContentModel
    
    weak var delegate: ContentVideoPlayerCoordinatorDelegate?
    
    init?(content: ContentModel) {
        self.content = content
        
        guard let asset = content.assets.first else {
            return nil
        }
        
        if content.type == .video && asset.videoSource == .youtube {
            videoPlayer = YouTubeVideoPlayer()
        }
        else {
            videoPlayer = VVideoView()
        }
        
        videoPlayer.view.backgroundColor = .clearColor()
        
        super.init()
        
        videoPlayer.delegate = self
        toolbar.delegate = self
    }
    
    func tearDown() {
        videoPlayer.view.removeFromSuperview()
        toolbar.removeFromSuperview()
    }
    
    func loadVideo() {
        guard let asset = content.assets.first else {
            assertionFailure("There were no assets for this piece of content.")
            return
        }
        
        let item: VVideoPlayerItem?
        
        if asset.videoSource == .youtube {
            item = VVideoPlayerItem(externalID: asset.resourceID)
        }
        else if let resourceURL = NSURL(string: asset.resourceID) {
            item = VVideoPlayerItem(URL: resourceURL)
        }
        else {
            return
        }
        
        if let item = item {
            item.loop = content.shouldLoop
            item.useAspectFit = true
            videoPlayer.setItem(item)
        }
    }
    
    // MARK: - Managing the video player
    
    private let videoPlayer: VVideoPlayer
    
    var duration: Double {
        return videoPlayer.durationSeconds
    }
    
    func setupVideoPlayer(in superview: UIView) {
        superview.addSubview(videoPlayer.view)
    }
    
    // MARK: - Managing the toolbar
    
    private let toolbar = VideoToolbarView.viewFromNib()
    
    func setupToolbar(in superview: UIView, initallyVisible visible: Bool) {
        superview.addSubview(toolbar)
        toolbar.v_addHeightConstraint(Constants.toolbarHeight)
        superview.v_addPinToLeadingTrailingToSubview(toolbar)
        superview.v_addPinToBottomToSubview(toolbar)
        toolbar.setVisible(visible)
    }
    
    func toggleToolbarVisibility(animated: Bool) {
        toolbar.setVisible(!toolbar.isVisible, animated: animated)
    }
    
    // MARK: - Managing playback

    /// Plays the video belonging to the content passed in during initialization.
    /// `synced` can be used to enable the syncing feature where the video would be synced between all users of the app.
    func playVideo(withSync synced: Bool = false) {
        if synced {
            let seekAheadTime = content.seekAheadTime()
            if Int(videoPlayer.currentTimeSeconds) <= Int(seekAheadTime) {
                videoPlayer.seekToTimeSeconds(seekAheadTime)
            }
        }
        videoPlayer.play()
        state = .Playing
    }
    
    func pauseVideo() {
        videoPlayer.pause()
    }
    
    var isPlaying: Bool {
        return videoPlayer.isPlaying
    }
    
    private func prepareToPlay() {
        let seekAheadTime = content.seekAheadTime()
        if Int(videoPlayer.currentTimeSeconds) <= Int(seekAheadTime) {
            videoPlayer.seekToTimeSeconds(seekAheadTime)
        }
        delegate?.coordinatorDidBecomeReady()
    }
    
    // MARK: - Layout

    func layout(in bounds: CGRect, with fillMode: FillMode = .fit) {
        let boundsAspectRatio = bounds.size.aspectRatio
        
        if let contentAspectRatio = content.naturalMediaAspectRatio where contentAspectRatio != boundsAspectRatio && (fillMode == .fill) {
            // This expands the frame of the video player to fill the given bounds.
            let difference = fabs(boundsAspectRatio - contentAspectRatio)
            
            videoPlayer.view.frame = bounds.insetBy(
                dx: -bounds.size.width * difference,
                dy: -bounds.size.height * difference
            )
        }
        else {
            videoPlayer.view.frame = bounds
        }
    }
    
    // MARK: - VVideoPlayerDelegate
    
    func videoPlayerDidBecomeReady(videoPlayer: VVideoPlayer) {
        guard let asset = content.assets.first where asset.videoSource == .youtube else {
            return
        }
        prepareToPlay()
    }
    
    func videoPlayerItemIsReadyToPlay(videoPlayer: VVideoPlayer) {
        prepareToPlay()
    }
    
    func videoPlayerDidReachEnd(videoPlayer: VVideoPlayer) {
        state = .Ended
    }
    
    func videoPlayerDidStartBuffering(videoPlayer: VVideoPlayer) {
        if state != .Scrubbing && state != .Paused {
            state = .Buffering
        }
    }
    
    func videoPlayer(videoPlayer: VVideoPlayer, didPlayToTime time: Float64) {
        toolbar.setCurrentTime(videoPlayer.currentTimeSeconds, duration: videoPlayer.durationSeconds)
    }
    
    func videoPlayerDidPlay(videoPlayer: VVideoPlayer) {
        state = .Playing
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

private extension ContentModel {
    var shouldLoop: Bool {
        return type == .gif
    }
}
