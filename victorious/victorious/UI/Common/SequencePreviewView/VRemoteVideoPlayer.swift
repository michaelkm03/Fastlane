//
//  VRemoteVideoSequencePreviewView.swift
//  victorious
//
//  Created by Patrick Lynch on 9/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class VRemoteVideoPlayer : NSObject, VVideoPlayer, YTPlayerViewDelegate {
    
    private static var sharedPlayerView: YTPlayerView?
    
    lazy private var playerView: YTPlayerView = {
        if let player = sharedPlayerView {
            player.userInteractionEnabled = false
            return player
        } else {
            let player = YTPlayerView()
            player.backgroundColor = UIColor.clearColor()
            sharedPlayerView = player
            return player
        }
    }()
    
    // MARK: - VVideoPlayer
    
    var useAspectFit = false
    var muted = false
    
    var isPlaying: Bool {
        return self.playerView.playbackRate() > 0.0
    }
    
    var currentTimeMilliseconds: UInt {
        return UInt( self.playerView.currentTime() * 1000.0 )
    }
    
    var currentTimeSeconds: Float64 {
        return Float64( self.playerView.currentTime() )
    }
    
    var durationSeconds: Float64 {
        return Float64( self.playerView.duration() )
    }
    
    weak var delegate: VVideoPlayerDelegate?
    
    var view: UIView {
        return self.playerView
    }
    
    func setItem(item: VVideoPlayerItem) {
        let playerVars = [
            "controls" : NSNumber(integer: 0),
            "playsinline" : NSNumber(integer: 1),
            "autohide" : NSNumber(integer: 1),
            "showinfo" : NSNumber(integer: 0),
            "modestbranding" : NSNumber(integer: 1)
        ]
        self.playerView.delegate = self
        
        guard let videoId = item.remoteContentId else {
            fatalError( "Remote content ID is required for this video player." )
        }
        
        if self.playerView.videoUrl() == nil {
            print( "Initializing video player" )
            self.playerView.loadWithVideoId( videoId, playerVars: playerVars )
        }
        else {
            print( "Using existing video player" )
            self.playerView.cueVideoById( videoId, startSeconds: 0.0, suggestedQuality: .Auto )
        }
        self.playerView.hidden = false
    }
    
    func seekToTimeSeconds(timeSeconds: NSTimeInterval) {
        self.playerView.seekToSeconds( Float(timeSeconds), allowSeekAhead: true)
    }
    
    func play() {
        self.playerView.hidden = false
        self.playerView.playVideo()
        self.delegate?.videoPlayerDidPlay?(self)
    }
    
    func pause() {
        self.playerView.hidden = false
        self.playerView.pauseVideo()
    }
    
    func pauseAtStart() {
        self.playerView.seekToSeconds( 0.0, allowSeekAhead: true)
        self.playerView.hidden = false
        self.playerView.pauseVideo()
    }
    
    func playFromStart() {
        self.playerView.seekToSeconds( 0.0, allowSeekAhead: true)
        self.playerView.hidden = false
        self.playerView.playVideo()
        self.delegate?.videoPlayerDidPlay?(self)
    }
    
    // MARK: - YTPlayerViewDelegate
    
    func playerViewDidBecomeReady(playerView: YTPlayerView!) {
        self.delegate?.videoPlayerDidBecomeReady?(self)
        self.play()
    }
    
    func playerView(playerView: YTPlayerView!, didChangeToState state: YTPlayerState) {
        switch state {
        case .Ended:
            self.delegate?.videoPlayerDidReachEnd?(self)
        case .Paused:
            self.delegate?.videoPlayerDidPause?(self)
        case .Buffering:
            self.delegate?.videoPlayerDidStartBuffering?(self)
        case .Queued:()
        case .Unknown:()
        case .Unstarted:()
        case .Playing:()
        }
    }
    
    func playerView(playerView: YTPlayerView!, didChangeToQuality quality: YTPlaybackQuality) {}
    
    func playerView(playerView: YTPlayerView!, receivedError error: YTPlayerError) {
        print( "YTPlayerView receivedError = \(error)" )
    }
    
    func playerView(playerView: YTPlayerView!, didPlayTime playTime: Float) {
        self.delegate?.videoPlayer?(self, didPlayToTime: Float64(playTime) )
    }
}
