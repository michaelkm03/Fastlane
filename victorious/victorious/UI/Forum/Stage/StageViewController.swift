//
//  StageViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK
import SDWebImage

class StageViewController: UIViewController, Stage, VVideoPlayerDelegate {
    
    private struct Constants {
        static let contentSizeAnimationDuration: NSTimeInterval = 0.5
        static let contentHideAnimationDuration: NSTimeInterval = 0.5
        static let fixedStageHeight: CGFloat = 200.0
    }
    
    private struct InterruptMessageConstants {
        static let videoPlayerKey = "videoPlayer"
    }
    
    /// The content view that is grows and shrinks depending on the content it is displaying.
    /// Is is also this size that will be broadcasted to the stage delegate.
    @IBOutlet private weak var mainContentView: UIView!
    @IBOutlet private weak var mainContentViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var videoContentView: UIView!
    
    private lazy var videoPlayer: VVideoView = self.setupVideoView(self.videoContentView)
    
    private var currentContentView: UIView?
    
    private var currentStagedMedia: Stageable?
    
    private var playbackInterrupterTimer: NSTimer?

    weak var delegate: StageDelegate?
    
    var dependencyManager: VDependencyManager!
    
    // MARK: UIViewController
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        terminateInterrupterTimer()
    }
    
    //MARK: - Stage
    
    func startPlayingMedia(media: Stageable) {
        terminateInterrupterTimer()
        videoPlayer.pause()
        currentStagedMedia = media
        
        switch media {
        case let videoAsset as VideoAsset:
            addVideoAsset(videoAsset)
        case let imageAsset as ImageAsset:
            addImageAsset(imageAsset)
        case let gifAsset as GifAsset:
            addGifAsset(gifAsset)
        default:
            assertionFailure("Unknown stagable type: \(media)")
        }
        delegate?.stage(self, didUpdateContentHeight: Constants.fixedStageHeight)
    }
    
    func stopPlayingMedia() {
        clearStageMedia()
    }
    
    // MARK: - VVideoPlayerDelegate
    
    func videoPlayerDidBecomeReady(videoPlayer: VVideoPlayer) {
        switchToContentView(videoContentView, fromContentView: currentContentView)
        videoPlayer.playFromStart()
    }
    
    // MARK: Video
    
    private func setupVideoView(containerView: UIView) -> VVideoView {
        let videoPlayer = VVideoView(frame: self.videoContentView.bounds)
        videoPlayer.useAspectFit = false
        videoPlayer.delegate = self
        videoPlayer.backgroundColor = UIColor.clearColor()
        containerView.addSubview(videoPlayer.view)
        containerView.v_addFitToParentConstraintsToSubview(videoPlayer.view)
        
        return videoPlayer
    }
    
    // MARK: - ForumEventReceiver {
    
    func receiveEvent(event: ForumEvent) {
        
    }
    
    // MARK: Video Asset
    
    private func addVideoAsset(videoAsset: VideoAsset) {
        let videoItem = VVideoPlayerItem(URL: videoAsset.mediaMetaData.url)
        videoPlayer.setItem(videoItem)
    }
    
    // MARK: Image Asset
    
    private func addImageAsset(imageAsset: ImageAsset) {
        imageView.sd_setImageWithURL(imageAsset.mediaMetaData.url) { [weak self] (image, error, cacheType, url) in
            guard let strongSelf = self else {
                return
            }
            
            guard let stageImageUrl = strongSelf.currentStagedMedia?.mediaMetaData.url where stageImageUrl == url else {
                return
            }
            
            strongSelf.switchToContentView(strongSelf.imageView, fromContentView: strongSelf.currentContentView)
        }
    }
    
    // MARK: Gif Playback
    
    private func addGifAsset(gifAsset: GifAsset) {
        let videoItem = VVideoPlayerItem(URL: gifAsset.mediaMetaData.url)
        videoItem.loop = true
        videoPlayer.setItem(videoItem)
        
        if let duration = gifAsset.mediaMetaData.duration {
            let interruptMessage = [InterruptMessageConstants.videoPlayerKey: videoPlayer]
            playbackInterrupterTimer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: "interruptPlayback:", userInfo: interruptMessage, repeats: false)
        }
    }
    
    // MARK: Interrupt Playback Timer
    
    @objc private func interruptPlayback(timer: NSTimer) {
        if let interruptMessage = timer.userInfo as? NSDictionary {
            if let videoPlayer = interruptMessage[InterruptMessageConstants.videoPlayerKey] as? VVideoPlayer {
                videoPlayer.pause()
            }
        }
        
        timer.invalidate()
    }
    
    private func terminateInterrupterTimer() {
        playbackInterrupterTimer?.invalidate()
        playbackInterrupterTimer = nil
    }
    
    // MARK: Clear Media
    
    private func switchToContentView(newContentView: UIView, fromContentView oldContentView: UIView?) {
        if newContentView != oldContentView {
            UIView.animateWithDuration(Constants.contentHideAnimationDuration) {
                newContentView.alpha = 1.0
                oldContentView?.alpha = 0.0
            }
        }
        currentContentView = newContentView
        
        let height = currentStagedMedia?.mediaMetaData.size?.height ?? Constants.fixedStageHeight
        let clampedHeight = min(height, Constants.fixedStageHeight)
        delegate?.stage(self, didUpdateContentHeight: clampedHeight)
    }
    
    private func clearStageMedia() {
        mainContentViewBottomConstraint.constant = 0
        UIView.animateWithDuration(Constants.contentSizeAnimationDuration) {
            self.delegate?.stage(self, didUpdateContentHeight:0.0)
            self.view.layoutIfNeeded()
        }
    }
}
