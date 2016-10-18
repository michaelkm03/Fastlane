//
//  VContentVideoPlayerCoordinator.swift
//  victorious
//
//  Created by Vincent Ho on 4/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

enum VideoState {
    case buffering,
    ended,
    notStarted,
    paused,
    playing,
    scrubbing
}

protocol ContentVideoPlayerCoordinatorDelegate: class {
    func coordinatorDidBecomeReady()

    func coordinatorDidFinishPlaying()
}

/// A coordinator that holds a VVideoView object adjusting for different types of Content 
/// (currently supporting GIFs, videos, and youtube videos)
/// Sets up the video view and handles replay/buffering/scrubbing logic
class VContentVideoPlayerCoordinator: NSObject, VVideoPlayerDelegate, VideoToolbarDelegate {
    private struct Constants {
        static let toolbarHeight = CGFloat(41.0)
    }

    private var lastState: VideoState = .notStarted
    private var state: VideoState = .notStarted {
        didSet {
            lastState = oldValue
            toolbar.paused = state != .playing
        }
    }
    private var content: Content
    
    weak var delegate: ContentVideoPlayerCoordinatorDelegate?
    
    init?(content: Content) {
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
        
        videoPlayer.view.backgroundColor = .clear
        
        super.init()
        
        videoPlayer.delegate = self
        toolbar.delegate = self
    }
    
    func tearDown() {
        videoPlayer.view.removeFromSuperview()
        toolbar.removeFromSuperview()
    }
    
    func loadVideo() {
        guard let asset = content.assets.first, let resourceID = asset.resourceID else {
            assertionFailure("Failed to load the asset for this piece of content -> \(content)")
            return
        }

        let item: VVideoPlayerItem
        if asset.videoSource == .youtube {
            item = VVideoPlayerItem(externalID: resourceID)
        }
        else if let resourceURL = URL(string: resourceID) {
            item = VVideoPlayerItem(url: resourceURL)
        }
        else {
            return
        }
        
        item.loop = content.shouldLoop
        item.useAspectFit = true
        videoPlayer.setItem(item)
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
        superview.v_addPinToLeadingTrailing(toSubview: toolbar)
        superview.v_addPinToBottom(toSubview: toolbar)
        toolbar.setVisible(visible)
    }
    
    func toggleToolbarVisibility(_ animated: Bool) {
        toolbar.setVisible(!toolbar.isVisible, animated: animated)
    }
    
    // MARK: - Managing playback

    /// Plays the video belonging to the content passed in during initialization.
    /// `synced` can be used to enable the syncing feature where the video would be synced between all users of the app.
    func playVideo(withSync synced: Bool = false) {
        if let seekAheadTime = content.seekAheadTime , synced {
            if Int(videoPlayer.currentTimeSeconds) <= Int(seekAheadTime) {
                videoPlayer.seek(toTimeSeconds: seekAheadTime)
            }
        }
        videoPlayer.play()
        state = .playing
    }
    
    func pauseVideo() {
        videoPlayer.pause()
    }
    
    var isPlaying: Bool {
        return videoPlayer.isPlaying
    }
    
    private func prepareToPlay() {
        if let seekAheadTime = content.seekAheadTime , Int(videoPlayer.currentTimeSeconds) <= Int(seekAheadTime) {
            videoPlayer.seek(toTimeSeconds: seekAheadTime)
        }
        delegate?.coordinatorDidBecomeReady()
    }
    
    // MARK: - Layout

    func layout(in bounds: CGRect, with fillMode: FillMode = .fit) {
        let boundsAspectRatio = bounds.size.aspectRatio ?? 1
        
        if let contentAspectRatio = content.naturalMediaAspectRatio , contentAspectRatio != boundsAspectRatio && (fillMode == .fill) {
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
    
    func videoPlayerDidBecomeReady(_ videoPlayer: VVideoPlayer) {
        guard let asset = content.assets.first , asset.videoSource == .youtube else {
            return
        }
        prepareToPlay()
    }
    
    func videoPlayerItemIsReady(toPlay videoPlayer: VVideoPlayer) {
        prepareToPlay()
    }
    
    func videoPlayerDidReachEnd(_ videoPlayer: VVideoPlayer) {
        state = .ended
        delegate?.coordinatorDidFinishPlaying()
    }
    
    func videoPlayerDidStartBuffering(_ videoPlayer: VVideoPlayer) {
        if state != .scrubbing && state != .paused {
            state = .buffering
        }
    }
    
    func videoPlayer(_ videoPlayer: VVideoPlayer, didPlayToTime time: Float64) {
        toolbar.setCurrentTime(videoPlayer.currentTimeSeconds, duration: videoPlayer.durationSeconds)
    }
    
    func videoPlayerDidPlay(_ videoPlayer: VVideoPlayer) {
        state = .playing
    }
    
    func videoPlayerDidPause(_ videoPlayer: VVideoPlayer) {
        if state != .notStarted && state != .scrubbing {
            state = .paused
        }
    }
    
    // MARK: - VideoToolbarDelegate
    
    func videoToolbarDidPlay(_ videoToolbar: VideoToolbarView) {
        videoPlayer.play()
    }
    
    func videoToolbarDidPause(_ videoToolbar: VideoToolbarView) {
        videoPlayer.pause()
    }
    
    func videoToolbar(_ videoToolbar: VideoToolbarView, didScrubToLocation location: Float) {
        let timeSeconds: TimeInterval = Double(location) * videoPlayer.durationSeconds
        videoPlayer.seek(toTimeSeconds: timeSeconds)
    }
    
    func videoToolbar(_ videoToolbar: VideoToolbarView, didEndScrubbingToLocation location: Float) {
        if lastState == .playing {
            videoPlayer.play()
        }
        else {
            videoPlayer.pause()
        }
    }
    
    func videoToolbar(_ videoToolbar: VideoToolbarView, didStartScrubbingToLocation location: Float) {
        state = .scrubbing
        videoPlayer.pause()
    }
}

private extension Content {
    var shouldLoop: Bool {
        return type == .gif
    }
}
