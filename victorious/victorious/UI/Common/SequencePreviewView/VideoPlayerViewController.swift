//
//  VideoPlayerViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

@objc protocol VideoPlayerDelegate {
    func videoPlayer( videoPlayer: VideoPlayer, didPlayToQuartile quartile: UInt )
    func videoPlayerDidBecomeReadyForPlayback( videoPlayer: VideoPlayer )
    func videoPlayerDidEndPlayback( videoPlayer: VideoPlayer )
    func videoPlayerDidStartPlayback( videoPlayer: VideoPlayer )
}

@objc enum VideoPlayerAspect: Int {
    case Fit, Fill
}

@objc protocol VideoPlayer {
    func play()
    func playFromStart()
    func pause()
    func seek( time: NSTimeInterval )
    
    var videoURL: NSURL? { set get }
    var delegate: VideoPlayerDelegate? { set get }
    
    var mute: Bool { set get }
    var loop: Bool { set get }
    var showControls: Bool { set get }
    
    var currentTime: NSTimeInterval { get }
    var duration: NSTimeInterval { get }
    var aspect: VideoPlayerAspect { set get }
}

class VideoPlayerViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet private weak var videoViewContainer: UIView!
    @IBOutlet private weak var toolbarContainer: UIView!
    
    private var videoView: UIView?
    private var videoPlayer: VideoPlayer?
    
    var showToolbar: Bool = false {
        didSet {
            self.updateControls()
        }
    }
    
    func setVideoPlayer( videoPlayer: VideoPlayer, withVideoView videoView: UIView, withToolbar: Bool = false ) {
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
}