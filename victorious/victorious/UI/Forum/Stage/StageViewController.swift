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
    }
    
    /// The content view that is grows and shrinks depending on the content it is displaying.
    /// Is is also this size that will be broadcasted to the stage delegate.
    @IBOutlet private weak var mainContentView: UIView!
    @IBOutlet weak var mainContentViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var videoContentView: UIView!
    
    private lazy var videoPlayer: VVideoView = self.setupVideoView(self.videoContentView)
    
    private var currentContentView: UIView?
    
    private var currentStagedMedia: Stageable?
    
    private var playbackInterrupterTimer: NSTimer?
    
    var dependencyManager: VDependencyManager!

    
    // MARK: UIViewController
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        terminateInterrupterTimer()
    }
    
    // TODO: remove this before merge into dev !!! !!! !!!
    private func senasDemoCode() {
        
        let gradient = VLinearGradientView()
        gradient.setColors([UIColor.lightGrayColor(), UIColor.blueColor()])
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        self.view.addSubview(gradient)
        gradient.frame = self.view.bounds
        self.view.sendSubviewToBack(gradient)
        
        
        var gifAssetJson: JSON = JSON([
            "mimeType": "MP4",
            //            "data": "http://media2.giphy.com/media/FiGiRei2ICzzG/giphy.mp4",
            "height": "200",
            "width": "100",
            "bitrate": "200",
            "duration": 8,
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
            "duration": 10,
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
            "duration": 10,
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
    }
    
    func stopPlayingMedia() {
        clearStageMedia()
    }
    
    
    // MARK: - VVideoPlayerDelegate 

    func videoPlayerDidBecomeReady(videoPlayer: VVideoPlayer) {
        switchToContentView(videoContentView, fromContentView: currentContentView)
        videoPlayer.playFromStart()
    }
    
    
    // MARK: - Private
    
    private func normalizeSize(size: CGSize) -> CGSize {
        let normalizedHeight = min(size.height, Constants.fixedStageSize.height)
        let normalizedSize = CGSize(width: Constants.fixedStageSize.width, height: normalizedHeight)
        return normalizedSize
    }
    
    // MARK: Video
    
    private func setupVideoView(containerView: UIView) -> VVideoView {
        let videoPlayer = VVideoView(frame: self.videoContentView.bounds)
        videoPlayer.useAspectFit = true
        videoPlayer.delegate = self
        
        containerView.addSubview(videoPlayer.view)
        containerView.v_addFitToParentConstraintsToSubview(videoPlayer.view)
        
        return videoPlayer
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
        
        var contentSize = currentStagedMedia?.mediaMetaData.size ?? Constants.fixedStageSize
        contentSize = normalizeSize(contentSize)
        delegate?.stage(self, didUpdateContentSize: contentSize)
    }
    
    private func clearStageMedia() {
        mainContentViewBottomConstraint.constant = 0
        UIView.animateWithDuration(Constants.contentSizeAnimationDuration) {
            self.view.layoutIfNeeded()
        }
        delegate?.stage(self, didUpdateContentSize: CGSizeZero)
        
        videoPlayer.pause()
    }
}
