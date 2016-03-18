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
        static let fixedStageSize = CGSize(width: UIScreen.mainScreen().bounds.size.width, height: 200.0)
    }
    
    private struct InterruptMessageConstants {
        static let videoPlayerKey = "videoPlayer"
        static let contentViewKey = "contentView"
    }
    
    /// The content view that is grows and shrinks depending on the content it is displaying.
    /// Is is also this size that will be broadcasted to the stage delegate.
    @IBOutlet private weak var mainContentView: UIView! {
        didSet {
            mainContentView.layer.shadowColor = UIColor.blackColor().CGColor
            mainContentView.layer.shadowRadius = 4.0
            mainContentView.layer.shadowOpacity = 1.0
            mainContentView.layer.shadowOffset = CGSize(width:0, height:2)
        }
    }
    @IBOutlet weak var mainContentViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var videoContentView: UIView!
    
    private lazy var videoPlayer: VVideoView = self.setupVideoView(self.videoContentView)
    
    private var currentContentView: UIView?
    
    private var playbackInterrupterTimer: NSTimer?
    
    var dependencyManager: VDependencyManager!
    
    // MARK: UIViewController
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        terminateInterrupterTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("stageSize -> \(Constants.fixedStageSize)")
        senasDemoCode()
    }
    
    // TODO: remove this before merge into dev !!! !!! !!!
    private func senasDemoCode() {
        
        
        var gifAssetJson: JSON = JSON([
            "mimeType": "MP4",
            //            "data": "http://media2.giphy.com/media/FiGiRei2ICzzG/giphy.mp4",
            "height": "200",
            "width": "100",
            "bitrate": "200",
            "duration": 2,
            "start_time": 100,
            //            "endTime": "12345678",
            "resourceLocation": "https://media.giphy.com/media/mbgpTdJmNkLAs/giphy.mp4"
            ])
        
        let gifAsset = GifAsset(json: gifAssetJson)
        
        gifAssetJson["resourceLocation"] = "https://media.giphy.com/media/PXXf6yHelzoXu/giphy.mp4"
        let gifAsset2 = GifAsset(json: gifAssetJson)
        
        gifAssetJson["resourceLocation"] = "https://media.giphy.com/media/vfz5C2BWduo36/giphy.mp4"
        let gifAsset3 = GifAsset(json: gifAssetJson)
        
        var videoAssetJson: JSON = JSON([
            "mimeType": "MP4",
            "data": "http://media2.giphy.com/media/FiGiRei2ICzzG/giphy.mp4",
            "height": "200",
            "width": "100",
            "bitrate": "200",
            "duration": 2,
            "start_time": 100,
            //            "endTime": "12345678",
            "resourceLocation": "http://media2.giphy.com/media/FiGiRei2ICzzG/giphy.mp4"
            ])
        
        let videoAsset = VideoAsset(json: videoAssetJson)
        
        videoAssetJson["resourceLocation"] = "http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8"
        let videoAsset2 = VideoAsset(json: videoAssetJson)
        
        videoAssetJson["resourceLocation"] = "http://cdn-fms.rbs.com.br/vod/hls_sample1_manifest.m3u8"
        let videoAsset3 = VideoAsset(json: videoAssetJson)
        
        var imageAssetJson: JSON = JSON([
            "image_url": "http://media.mydogspace.com.s3.amazonaws.com/wp-content/uploads/2013/08/puppy-500x350.jpg",
            "height": 200,
            "width": 100,
            "duration": 2,
            "type": "image",
            //            "endTime": "12345678",
            //            "resourceLocation": "http://media2.giphy.com/media/FiGiRei2ICzzG/giphy.mp4"
            ])
        
        let imageAsset = ImageAsset(json: imageAssetJson)
        
        imageAssetJson["image_url"] = "http://moto.zombdrive.com/images/motocross-1.jpg"
        let imageAsset2 = ImageAsset(json: imageAssetJson)
        
        imageAssetJson["image_url"] = "http://moto.zombdrive.com/images/motocross-2.jpg"
        let imageAsset3 = ImageAsset(json: imageAssetJson)
        
        let assets: [Stageable] = ([videoAsset, gifAsset, imageAsset, gifAsset2, videoAsset2, imageAsset2, gifAsset3, imageAsset3, videoAsset3] as [Stageable?]).flatMap { $0 }
        
        var delay: NSTimeInterval = 5
        
        print("-------------- NEW RANDOMIZED STAGE SCHEDULE -----------------")
        for asset in assets {
            dispatch_after(delay) { [weak self] in
                self?.startPlayingMedia(asset)
            }
            delay += NSTimeInterval(10)
            //            delay += NSTimeInterval(5 + arc4random_uniform(5))
        }
    }
    
    
    //MARK: - Stage
    
    weak var delegate: StageDelegate?
    
    func startPlayingMedia(media: Stageable) {
        terminateInterrupterTimer()
        
        switch media {
        case let videoAsset as VideoAsset:
            addVideoAsset(videoAsset)
        case let imageAsset as ImageAsset:
            addImageAsset(imageAsset)
        case let gifAsset as GifAsset:
            addGifAsset(gifAsset)
            // TODO: decide how we handle the close VIP stage command
            //        case let emptyAsset as EmptyAsset:
            //            clearStageMedia()
        default:
            assertionFailure("Unknown stagable type!")
        }
        
        delegate?.stage(self, didUpdateWithMedia: media)
        delegate?.stage(self, didUpdateContentSize: Constants.fixedStageSize)
    }
    
    func stopPlayingMedia() {
        clearStageMedia()
    }
    
    // MARK: - VVideoPlayerDelegate
    
    func videoPlayerDidBecomeReady(videoPlayer: VVideoPlayer) {
        videoPlayer.playFromStart()
    }
    
    func videoPlayerDidReachEnd(videoPlayer: VVideoPlayer) {
        videoPlayer.pauseAtStart()
    }
    
    // MARK: - Private
    
    // TODO: get size of content for setting `mainContentViewBottomConstraint.constant`
    
    // MARK: Video
    
    private func setupVideoView(containerView: UIView) -> VVideoView {
        let videoPlayer = VVideoView(frame: self.videoContentView.bounds)
        // TODO: remove muted when we deploy
        //        videoPlayer.muted = true
        videoPlayer.useAspectFit = true
        videoPlayer.delegate = self
        videoPlayer.backgroundColor = UIColor.clearColor()
        containerView.addSubview(videoPlayer.view)
        containerView.v_addFitToParentConstraintsToSubview(videoPlayer.view)
        
        return videoPlayer
    }
    
    // MARK: Video Asset
    
    private func addVideoAsset(videoAsset: VideoAsset) {
        NSLog("addVideoAsset -> \(videoAsset.url.absoluteString)")
        
        let videoItem = VVideoPlayerItem(URL: videoAsset.url)
        videoPlayer.setItem(videoItem)
        
        switchToContentView(videoContentView, fromContentView: currentContentView)
    }
    
    // MARK: Image Asset
    
    private func addImageAsset(imageAsset: ImageAsset) {
        NSLog("addImageAsset -> \(imageAsset.url.absoluteString)")
        imageView.sd_setImageWithURL(imageAsset.url)
        switchToContentView(imageView, fromContentView: currentContentView)
    }
    
    // MARK: Gif Playback
    
    private func addGifAsset(gifAsset: GifAsset) {
        NSLog("addGifAsset -> \(gifAsset.url.absoluteString)")
        
        let videoItem = VVideoPlayerItem(URL: gifAsset.url)
        videoItem.loop = true
        videoPlayer.setItem(videoItem)
        videoPlayer.playFromStart()
        
        // TODO: put this logics in the ScheduleStage(DataSource|Controller|Manager)
        if let duration = gifAsset.duration {
            let interruptMessage = [InterruptMessageConstants.videoPlayerKey: videoPlayer, InterruptMessageConstants.contentViewKey: videoContentView]
            playbackInterrupterTimer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: "interruptPlayback:", userInfo: interruptMessage, repeats: false)
        }
        
        switchToContentView(videoContentView, fromContentView: currentContentView)
    }
    
    // MARK: Interrupt Playback Timer
    
    @objc private func interruptPlayback(timer: NSTimer) {
        print("INTERRUPT TIMER KICKED IN!")
        
        if let interruptMessage = timer.userInfo as? NSDictionary {
            if let videoPlayer = interruptMessage[InterruptMessageConstants.videoPlayerKey] as? VVideoPlayer {
                videoPlayer.pause()
            }
            
            if let contentView = interruptMessage[InterruptMessageConstants.contentViewKey] as? UIView {
                contentView.alpha = 0.0
                currentContentView = nil
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
        mainContentView.userInteractionEnabled = true
        UIView.animateWithDuration(Constants.contentHideAnimationDuration) {
            newContentView.alpha = 1.0
            oldContentView?.alpha = 0.0
        }
        currentContentView = newContentView
    }
    
    private func clearStageMedia() {
        mainContentView.userInteractionEnabled = false
        mainContentViewBottomConstraint.constant = 0
        UIView.animateWithDuration(Constants.contentSizeAnimationDuration) {
            self.delegate?.stage(self, didUpdateContentSize: CGSize(width: self.view.bounds.width, height: 0.0))
            self.view.layoutIfNeeded()
        }
    }
}