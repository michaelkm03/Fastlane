//
//  YouTubeVideoPlayer.swift
//  victorious
//
//  Created by Patrick Lynch on 9/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

class YouTubeVideoPlayer: NSObject, VVideoPlayer, YTPlayerViewDelegate {

    private let playerView = YTPlayerView()
    
    private(set) var isPlaying: Bool = false

    private func updateMute() {
        if muted {
            playerView.mute()
        }
        else {
            playerView.unmute()
        }
    }
    
    func setItem(_ item: VVideoPlayerItem) {
        guard let videoId = item.remoteContentId else {
                assertionFailure("Cannot play video without setting a `VVideoPlayerItem` with a valid `remoteContentId` property.")
                return
        }

        playerView.delegate = self
        playerView.alpha = 0.0
        playerView.isUserInteractionEnabled = false
        delegate?.videoPlayerDidStartBuffering?(self)

        let container: [AnyHashable: Any] = [
            "videoId": videoId,
            "playerVars": playerVars
        ]
        playerView.load(withPlayerParams: container)
    }
    
    private var playerVars: [AnyHashable: Any] {
        // See https://developers.google.com/youtube/player_parameters for complete list
        return [
            "controls": NSNumber(value: 0 as Int),
            "rel": NSNumber(value: 0 as Int),
            "playsinline": NSNumber(value: 1 as Int),
            "autohide": NSNumber(value: 1 as Int),
            "showinfo": NSNumber(value: 0 as Int),
            "fs": NSNumber(value: 0 as Int),
            "modestbranding": NSNumber(value: 1 as Int),
            "enablejsapi": NSNumber(value: 1 as Int),
            "iv_load_policy": NSNumber(value: 3 as Int), ///< Removes annotations
            "autoplay": "0",
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
        return UInt(playerView.currentTime() * 1000.0)
    }
    
    var currentTimeSeconds: Float64 {
        return Float64(playerView.currentTime())
    }
    
    var durationSeconds: Float64 {
        return Float64(playerView.duration())
    }
    
    weak var delegate: VVideoPlayerDelegate?
    
    var view: UIView {
        return playerView
    }

    func seek(toTimeSeconds timeSeconds: TimeInterval) {
        playerView.seek(toSeconds: Float(timeSeconds), allowSeekAhead: true)
    }
    
    func reset() {
        playerView.clearVideo()
    }

    func play() {
        let wasPlaying = isPlaying
        if !wasPlaying {
            isPlaying = true
            playerView.playVideo()
            delegate?.videoPlayerDidPlay?(self)
        }
    }
    
    func pause() {
        playerView.pauseVideo()
    }
    
    func pauseAtStart() {
        playerView.seek(toSeconds: 0.0, allowSeekAhead: true)
        playerView.pauseVideo()
    }
    
    func playFromStart() {
        let wasPlaying = isPlaying
        if !wasPlaying {
            playerView.seek(toSeconds: 0.0, allowSeekAhead: true)
            playerView.playVideo()
        }
    }
    
    // MARK: - YTPlayerViewDelegate
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView!) {
        playerView.webView?.backgroundColor = UIColor.clear
        isPlaying = false
        delegate?.videoPlayerDidBecomeReady?(self)
        updateMute()

        // This is a sad hack to allow the youtube payer to play at all when entering CUV.
        if playerView.window == nil {
            playerView.pauseVideo()
        }
        else {
            playerView.playVideo()
        }
        
        if playerView.alpha < 1.0 {
            UIView.animate(
                withDuration: 0.3,
                delay: 0.2,
                options: [],
                animations: {
                    self.playerView.alpha = 1.0
                },
                completion: nil
            )
        }
    }
    
    func playerView(_ playerView: YTPlayerView!, didChangeTo state: YTPlayerState) {
        switch state {
            case .ended:
                playerView.isUserInteractionEnabled = true
                isPlaying = false
                delegate?.videoPlayerDidReachEnd?(self)
            case .paused:
                isPlaying = false
                delegate?.videoPlayerDidPause?(self)
            case .buffering:
                delegate?.videoPlayerDidStartBuffering?(self)
            case .queued: break
            case .unknown: break
            case .unstarted: break
            case .playing:
                playerView.isUserInteractionEnabled = false
                isPlaying = true
                delegate?.videoPlayerDidStopBuffering?(self)
                delegate?.videoPlayerDidPlay?(self)
        }
    }
    
    func playerView(_ playerView: YTPlayerView!, didChangeTo quality: YTPlaybackQuality) {}
    
    func playerView(_ playerView: YTPlayerView!, receivedError error: YTPlayerError) {
        print( "YTPlayerView receivedError = \(error)" )
    }
    
    func playerView(_ playerView: YTPlayerView!, didPlayTime playTime: Float) {
        delegate?.videoPlayer?(self, didPlayToTime: Float64(playTime) )
    }
    
    func update(toBackgroundColor backgroundColor: UIColor) {}
    
    var aspectRatio: CGFloat { return 1.0 }
}

// MARK: -

private extension YTPlayerView {
    
    func setVolume(_ level: Int) {
        _ = evaluate("player.setVolume( \(level) );")
    }
    
    func mute() {
        _ = evaluate("console.log( player )")
        _ = evaluate("player.mute();")
    }
    
    func unmute() {
        _ = evaluate("player.unMute();")
    }
    
    func evaluate( _ javaScriptString: String ) -> String? {
        if let webView = webView, let result = webView.stringByEvaluatingJavaScript(from: javaScriptString) {
            return result
        }
        return nil
    }
}
