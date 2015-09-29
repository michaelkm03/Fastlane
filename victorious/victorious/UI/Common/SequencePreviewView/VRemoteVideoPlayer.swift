//
//  VRemoteVideoSequencePreviewView.swift
//  victorious
//
//  Created by Patrick Lynch on 9/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

private extension YTPlayerView {
    
    func setVolume( level: Int ) {
        evaluate( "player.setVolume( \(level) );" )
    }
    
    func mute() {
        evaluate( "console.log( player )" )
        evaluate( "player.mute();" )
    }
    
    func unmute() {
        evaluate( "player.unMute();" )
    }
    
    func evaluate( javaScriptString: String ) -> String? {
        if let webView = self.webView, let result = webView.stringByEvaluatingJavaScriptFromString( javaScriptString ) {
            //print( "Evaluating javascript (\(javaScriptString)) -----> \(result)" )
            return result
        }
        return nil
    }
}

class VRemoteVideoPlayer : NSObject, VVideoPlayer, YTPlayerViewDelegate {
    
    private static var sharedPlayerView: YTPlayerView?
    private var currentItem: VVideoPlayerItem?
    
    /*lazy private var playerView: YTPlayerView = {
        if let player = sharedPlayerView {
            player.userInteractionEnabled = false
            return player
        } else {
            let player = YTPlayerView()
            player.backgroundColor = UIColor.clearColor()
            sharedPlayerView = player
            return player
        }
    }()*/
    
    let playerView = YTPlayerView()
    
    // MARK: - VVideoPlayer
    
    var useAspectFit = false {
        didSet {
            
        }
    }
    
    var muted = false {
        didSet {
            self.updateMute()
        }
    }
    
    private(set) var isPlaying: Bool = false
    
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
        
        self.currentItem = item
    }
    
    func loadCurrentItem() {
        guard let item = self.currentItem else {
            print( "Cannot play video without setting a `VVideoPlayerItem`" )
            return
        }
        
        let playerVars = [
            "controls" : NSNumber(integer: 1),
            "playsinline" : NSNumber(integer: 1),
            "autohide" : NSNumber(integer: 1),
            "showinfo" : NSNumber(integer: 0),
            "modestbranding" : NSNumber(integer: 1)
        ]
        self.playerView.delegate = self
        
        // WARNING: Testing only:
        let videoIds = [ "Z9XCCDQOgyQ", "jYm0WQf_sNI", "sAmz-Evlmxk", "LsKFsF2zpFM", "ZIKzHAS1N_U" ]
        item.remoteContentId = videoIds[ Int( arc4random() % UInt32(videoIds.count) )]
        
        guard let videoId = item.remoteContentId else {
            fatalError( "Remote content ID is required for this video player." )
        }
        
        self.playerView.hidden = true
        self.playerView.loadWithVideoId( videoId, playerVars: playerVars )
    }
    
    func seekToTimeSeconds(timeSeconds: NSTimeInterval) {
        self.playerView.seekToSeconds( Float(timeSeconds), allowSeekAhead: true)
    }
    
    func play() {
        let wasPlaying = self.isPlaying
        if !wasPlaying {
            self.isPlaying = true
            if self.playerView.videoUrl() == nil {
                self.loadCurrentItem()
            }
            
            self.playerView.playVideo()
            self.delegate?.videoPlayerDidPlay?(self)
        }
    }
    
    func pause() {
        if self.isPlaying {
            self.playerView.pauseVideo()
        }
    }
    
    func pauseAtStart() {
        if self.isPlaying {
            self.playerView.seekToSeconds( 0.0, allowSeekAhead: true)
            self.playerView.pauseVideo()
        }
    }
    
    func playFromStart() {
        let wasPlaying = self.isPlaying
        if !wasPlaying {
            if self.playerView.videoUrl() == nil {
                self.loadCurrentItem()
            }
            self.playerView.playVideo()
            self.delegate?.videoPlayerDidPlay?(self)
        }
        self.playerView.seekToSeconds( 0.0, allowSeekAhead: true)
    }
    
    // MARK: - YTPlayerViewDelegate
    
    func playerViewDidBecomeReady(playerView: YTPlayerView!) {
        self.playerView.stopVideo()
        self.isPlaying = false
        self.playerView.hidden = true
        self.delegate?.videoPlayerDidBecomeReady?(self)
        self.updateMute()
    }
    
    func playerView(playerView: YTPlayerView!, didChangeToState state: YTPlayerState) {
        switch state {
        case .Ended:
            self.isPlaying = false
            self.playerView.hidden = true
            self.delegate?.videoPlayerDidReachEnd?(self)
        case .Paused:
            self.isPlaying = false
            self.delegate?.videoPlayerDidPause?(self)
        case .Buffering:
            self.delegate?.videoPlayerDidStartBuffering?(self)
        case .Queued:()
        case .Unknown:()
        case .Unstarted:()
        case .Playing:
            self.isPlaying = true
            self.playerView.hidden = false
        }
    }
    
    func playerView(playerView: YTPlayerView!, didChangeToQuality quality: YTPlaybackQuality) {}
    
    func playerView(playerView: YTPlayerView!, receivedError error: YTPlayerError) {
        print( "YTPlayerView receivedError = \(error)" )
    }
    
    func playerView(playerView: YTPlayerView!, didPlayTime playTime: Float) {
        self.delegate?.videoPlayer?(self, didPlayToTime: Float64(playTime) )
    }
    
    private func updateMute() {
        if muted {
            playerView.mute()
        }
        else {
            playerView.mute()
        }
    }
}
