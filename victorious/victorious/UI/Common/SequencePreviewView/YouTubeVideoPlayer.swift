//
//  YouTubeVideoPlayer.swift
//  victorious
//
//  Created by Patrick Lynch on 9/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

class YouTubeVideoPlayer: NSObject, VVideoPlayer, YTPlayerViewDelegate {
    
    private var currentItem: VVideoPlayerItem?

    private let playerView = YTPlayerView()
    
    private(set) var isPlaying: Bool = false
    
    private var isReadyToPlay: Bool = false
    
    private func updateMute() {
        if muted {
            playerView.mute()
        }
        else {
            playerView.mute()
        }
    }
    
    private func loadCurrentItem() {
        guard let item = currentItem,
            let videoId = item.remoteContentId else {
                assertionFailure( "Cannot play video without setting a `VVideoPlayerItem` with a valid `remoteContentId` property." )
                return
        }
        
        playerView.delegate = self
        playerView.alpha = 0.0
        playerView.userInteractionEnabled = false
        delegate?.videoPlayerDidStartBuffering?(self)
        playerView.loadWithVideoId( videoId, playerVars: playerVars )
        playerView.playVideo()
        
        isReadyToPlay = true
    }
    
    private var playerVars: [NSObject: AnyObject] {
        // See https://developers.google.com/youtube/player_parameters for complete list
        return [
            "controls": NSNumber(integer: 0),
            "rel": NSNumber(integer: 0),
            "playsinline": NSNumber(integer: 1),
            "autohide": NSNumber(integer: 1),
            "showinfo": NSNumber(integer: 0),
            "fs": NSNumber(integer: 0),
            "modestbranding": NSNumber(integer: 1),
            "enablejsapi": NSNumber(integer: 1),
            "iv_load_policy": NSNumber(integer: 3), ///< Removes annotations
        ]
    }
    
    // MARK: - VVideoPlayer
    
    var useAspectFit = false
    
    var muted = false {
        didSet {
            updateMute()
        }
    }
    
    var currentTimeMilliseconds: UInt {
        return UInt( playerView.currentTime() * 1000.0 )
    }
    
    var currentTimeSeconds: Float64 {
        return Float64( playerView.currentTime() )
    }
    
    var durationSeconds: Float64 {
        return Float64( playerView.duration() )
    }
    
    weak var delegate: VVideoPlayerDelegate?
    
    var view: UIView {
        return playerView
    }
    
    func setItem(item: VVideoPlayerItem) {
        if currentItem?.remoteContentId != item.remoteContentId {
            self.reset()
        }
        currentItem = item
    }
    
    func seekToTimeSeconds(timeSeconds: NSTimeInterval) {
        playerView.seekToSeconds( Float(timeSeconds), allowSeekAhead: true)
    }
    
    func reset() {
        isReadyToPlay = false
        playerView.clearVideo()
    }
    
    func play() {
        let wasPlaying = isPlaying
        if !wasPlaying {
            isPlaying = true
            if !isReadyToPlay {
                loadCurrentItem()
            }
            
            playerView.playVideo()
            delegate?.videoPlayerDidPlay?(self)
        }
    }
    
    func pause() {
        playerView.pauseVideo()
    }
    
    func pauseAtStart() {
        playerView.seekToSeconds( 0.0, allowSeekAhead: true)
        playerView.pauseVideo()
    }
    
    func playFromStart() {
        let wasPlaying = isPlaying
        if !wasPlaying {
            if !isReadyToPlay {
                loadCurrentItem()
            }
            playerView.seekToSeconds( 0.0, allowSeekAhead: true)
            playerView.playVideo()
        }
    }
    
    // MARK: - YTPlayerViewDelegate
    
    func playerViewDidBecomeReady(playerView: YTPlayerView!) {
        playerView.webView?.backgroundColor = UIColor.clearColor()
        playerView.stopVideo()
        isPlaying = false
        delegate?.videoPlayerDidBecomeReady?(self)
        updateMute()
        
        if playerView.alpha < 1.0 {
            UIView.animateWithDuration( 0.3,
                delay: 0.2,
                options: [],
                animations: { () -> Void in
                    self.playerView.alpha = 1.0
                },
                completion: nil
            )
        }
    }
    
    func playerView(playerView: YTPlayerView!, didChangeToState state: YTPlayerState) {
        switch state {
        case .Ended:
            playerView.userInteractionEnabled = true
            isPlaying = false
            delegate?.videoPlayerDidReachEnd?(self)
        case .Paused:
            isPlaying = false
            delegate?.videoPlayerDidPause?(self)
        case .Buffering:
            delegate?.videoPlayerDidStartBuffering?(self)
        case .Queued:()
        case .Unknown:()
        case .Unstarted:()
        case .Playing:
            playerView.userInteractionEnabled = false
            isPlaying = true
            delegate?.videoPlayerDidStopBuffering?(self)
            delegate?.videoPlayerDidPlay?(self)
        }
    }
    
    func playerView(playerView: YTPlayerView!, didChangeToQuality quality: YTPlaybackQuality) {}
    
    func playerView(playerView: YTPlayerView!, receivedError error: YTPlayerError) {
        print( "YTPlayerView receivedError = \(error)" )
    }
    
    func playerView(playerView: YTPlayerView!, didPlayTime playTime: Float) {
        delegate?.videoPlayer?(self, didPlayToTime: Float64(playTime) )
    }
    
    func updateToBackgroundColor( backgroundColor: UIColor) {}
    
    var aspectRatio: CGFloat { return 1.0 }
}

// MARK: -

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
        if let webView = webView, let result = webView.stringByEvaluatingJavaScriptFromString( javaScriptString ) {
            //print( "Evaluating javascript (\(javaScriptString)) -----> \(result)" )
            return result
        }
        return nil
    }
}
