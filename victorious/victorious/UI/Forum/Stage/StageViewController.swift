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
    
    /// The content view that grows and shrinks depending on the content it is displaying.
    /// Is is also this size that will be broadcasted to the stage delegate.
    @IBOutlet private weak var mainContentView: UIView!
    @IBOutlet private weak var mainContentViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var videoContentView: UIView!
    
    private lazy var videoPlayer: VVideoView = self.setupVideoView(self.videoContentView)
    
    private var currentContentView: UIView?
    
    private var currentStagedContent: StageContent?
    
    private var stageDataSource: StageDataSource?
    
    weak var delegate: StageDelegate?
    
    var dependencyManager: VDependencyManager! {
        didSet {
            // The data source is initialized with the dependency manager since it needs URLs in the template to operate.
            stageDataSource = setupDataSource(dependencyManager)
        }
    }

    // MARK: Life cycle
    
    private func setupVideoView(containerView: UIView) -> VVideoView {
        let videoPlayer = VVideoView(frame: self.videoContentView.bounds)
        videoPlayer.useAspectFit = false
        videoPlayer.delegate = self
        videoPlayer.backgroundColor = UIColor.clearColor()
        containerView.addSubview(videoPlayer.view)
        containerView.v_addFitToParentConstraintsToSubview(videoPlayer.view)
        return videoPlayer
    }
    
    private func setupDataSource(dependencyManager: VDependencyManager) -> StageDataSource {
        let dataSource = StageDataSource(dependencyManager: dependencyManager)
        dataSource.delegate = self
        return dataSource
    }

    override func viewWillDisappear(animated: Bool) {
        clearStageMedia()
    }

    //MARK: - Stage
    
    func addContent(stageContent: StageContent) {
        videoPlayer.pause()
        currentStagedContent = stageContent

        switch stageContent {
        case .video:
            addVideoAsset(stageContent)
        case .image:
            addImageAsset(stageContent)
        case .gif:
            addGifAsset(stageContent)
        }
        delegate?.stage(self, didUpdateContentHeight: Constants.fixedStageHeight)
    }

    func removeContent() {
        clearStageMedia()
    }

    // MARK: - ForumEventReceiver
    
    var childEventReceivers: [ForumEventReceiver] {
        return [stageDataSource].flatMap { $0 }
    }
    
    func receive(event: ForumEvent) {}
    
    // MARK: - VVideoPlayerDelegate
    
    func videoPlayerDidBecomeReady(videoPlayer: VVideoPlayer) {
        switchToContentView(videoContentView, fromContentView: currentContentView)
        videoPlayer.play()
    }
    
    func videoPlayerItemIsReadyToPlay(videoPlayer: VVideoPlayer) {
        // This callback could happen multiple times so we don't want to queue up multiple seeks, therefore we need to compare the current time of the video to the actual seek.
        if let seekAheadTime = currentStagedContent?.seekAheadTime where Int(videoPlayer.currentTimeSeconds) <= Int(seekAheadTime) {
            videoPlayer.seekToTimeSeconds(seekAheadTime)
        }
    }
    
    func videoPlayerDidReachEnd(videoPlayer: VVideoPlayer) {
        currentStagedContent = nil
    }

    // MARK: Video Asset

    private func addVideoAsset(videoContent: StageContent) {
        let videoItem = VVideoPlayerItem(URL: videoContent.url)
        videoPlayer.setItem(videoItem)
    }

    // MARK: Image Asset
    
    private func addImageAsset(imageContent: StageContent) {
        imageView.sd_setImageWithURL(imageContent.url) { [weak self] (image, error, cacheType, url) in
            guard let strongSelf = self else {
                return
            }

            guard let stageImageURL = strongSelf.currentStagedContent?.url where stageImageURL == url else {
                return
            }
            
            strongSelf.switchToContentView(strongSelf.imageView, fromContentView: strongSelf.currentContentView)
        }
    }

    // MARK: Gif Playback
    
    private func addGifAsset(gifContent: StageContent) {
        let videoItem = VVideoPlayerItem(URL: gifContent.url)
        videoItem.loop = true
        videoPlayer.setItem(videoItem)
        videoPlayer.seekToTimeSeconds(0)
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
        mainContentViewBottomConstraint.constant = Constants.fixedStageHeight
        
        UIView.animateWithDuration(Constants.contentSizeAnimationDuration) {
            self.view.layoutIfNeeded()
        }

        delegate?.stage(self, didUpdateContentHeight: Constants.fixedStageHeight)
    }
    
    private func clearStageMedia(animated: Bool = false) {
        mainContentViewBottomConstraint.constant = 0
        
        UIView.animateWithDuration(animated == true ? Constants.contentSizeAnimationDuration : 0) {
            self.view.layoutIfNeeded()
        }
        self.delegate?.stage(self, didUpdateContentHeight: 0.0)
    }
}
