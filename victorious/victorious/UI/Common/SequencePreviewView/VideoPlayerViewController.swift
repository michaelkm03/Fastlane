//
//  VideoPlayerViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/*protocol VideoPlayerDelegate: NSObject {
    optional func videoPlayer( videoPlayer: VideoPlayer, didPlayToTime time: NSTimeInterval )
    optional func videoPlayerDidBecomeReadyForPlayback( videoPlayer: VideoPlayer )
    optional func videoPlayerDidEndPlayback( videoPlayer: VideoPlayer )
    optional func videoPlayerDidStartPlayback( videoPlayer: VideoPlayer )
    optional func videoPlayerDidStartBuffering( videoPlayer: VideoPlayer )
    optional func videoPlayerDidStopBuffering( videoPlayer: VideoPlayer )
}

protocol VideoPlayer: NSObject {
    func setItemURL( url: NSURL, loop: Bool, audioMuted: Bool, alongsideAnimation: (()->())? )
    
    func play()
    func playFromStart()
    func pause()
    func pauseFromStart()
    func seekToTimeSeconds( time: NSTimeInterval )
    
    weak var delegate:VideoPlayerDelegate?
    
    var muted: Bool { set get }
    var useAspectFit: Bool { set get }
    
    var isPlaying: Bool { get }
    var playbackBufferEmpty: Bool { get }
    var playbackLikelyToKeepUp: Bool { get }
    var currentTimeMilliseconds: UInt { get }
    var currentTimeSeconds: NSTimeInterval { get }
    var durationSeconds: NSTimeInterval { get }
}

class VideoPlayerViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet private weak var videoViewContainer: UIView!
    @IBOutlet private weak var toolbarContainer: UIView!
    
    private var videoPlayer: UIView?
    private var videoPlayer: VideoPlayer?
    
    var showToolbar: Bool = false {
        didSet {
            self.updateControls()
        }
    }
    
    func setVideoPlayer( videoPlayer: VideoPlayer, withVideoView videoPlayer: UIView, withToolbar: Bool = false ) {
        self.videoView = videoView
        self.videoPlayer = videoPlayer
        self.showToolbar = withToolbar
        
        self.updateControls()
    }
    
    func updateControls() {
        if self.showToolbar && self.toolbarContainer.subviews.count == 0 {
            var testView = UIView(frame: self.toolbarContainer.bounds)
            testView.backgroundColor = UIColor.redColor()
            self.toolbarContainer.addSubview( testView )
        }
        else if self.showToolbar && self.toolbarContainer.subviews.count > 0 {
            for obj in self.toolbarContainer.subviews {
                if let view = obj as? UIView {
                    view.removeFromSuperview()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var gestureRecognizer = UITapGestureRecognizer(target: self, action: "onDoubleTap")
        gestureRecognizer.numberOfTapsRequired = 2
        self.view.addGestureRecognizer( gestureRecognizer )
    }
    
    // MARK: - Target/action for UITapGestureRecognizer
    
    func onDoubleTap() {
        if var videoPlayer = self.videoPlayer {
            videoPlayer.aspect = videoPlayer.aspect == .Fit ? .Fill : .Fit
        }
    }
}*/