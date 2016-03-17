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
    }
    
    /// The content view that is grows and shrinks depending on the content it is displaying.
    /// Is is also this size that will be broadcasted to the stage delegate.
    @IBOutlet private weak var mainContentView: UIView!
    @IBOutlet weak var mainContentViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var videoContainerView: UIView!
    
    private lazy var videoPlayer: VVideoView = self.setupVideoView(self.videoContainerView)
    
    private var currentStagedMedia: Stageable?
    
    var dependencyManager: VDependencyManager!
    

    //MARK: - Stage
    
    weak var delegate: StageDelegate?
    
    func startPlayingMedia(media: Stageable) {
        currentStagedMedia = media

        switch media {
        case let videoAsset as VideoAsset:
            addVideoAsset(videoAsset)
        case let imageAsset as ImageAsset:
            addImageAsset(imageAsset)
        case let gifAsset as GifAsset:
            addGifAsset(gifAsset)
        // TODO: handle youtube videos
//        case let youtubeAsset as YouTubeAsset:
            
        // TODO: decide how we handle the close VIP stage command
//        case let emptyAsset as EmptyAsset:
//            clearStageMedia()
        default:
            print("Unknown stagable type!")
        }
        
        delegate?.stage(self, didUpdateWithMedia: media)
    }
    
    func stopPlayingMedia() {
        clearStageMedia()
    }
    
    
    // MARK: - VVideoPlayerDelegate 

    func videoPlayerDidBecomeReady(videoPlayer: VVideoPlayer) {
        videoPlayer.playFromStart()
    }
    
    func videoPlayerDidReachEnd(videoPlayer: VVideoPlayer) {
        clearStageMedia()
    }
    
    
    // MARK: - Private
    
    // TODO: get size of content for setting `mainContentViewBottomConstraint.constant`
    
    // MARK: Video
    
    private func playVideoUrl(videoUrl: NSURL) {
        view.bringSubviewToFront(videoContainerView)
        
        let videoItem = VVideoPlayerItem(URL: videoUrl)
        videoPlayer.setItem(videoItem)
        videoPlayer.playFromStart()
    }
    
    private func setupVideoView(containerView: UIView) -> VVideoView {
        let videoPlayer = VVideoView(frame: self.videoContainerView.bounds)
        // TODO: remove muted when we deploy
        videoPlayer.muted = true
        videoPlayer.useAspectFit = true
        videoPlayer.delegate = self
        
        containerView.addSubview(videoPlayer.view)
        containerView.v_addFitToParentConstraintsToSubview(videoPlayer.view)
        
        return videoPlayer
    }

    
    // MARK: Video Asset
    
    private func addVideoAsset(videoAsset: VideoAsset) {
        playVideoUrl(videoAsset.url)
    }

    
    // MARK: Image Asset
    
    private func addImageAsset(imageAsset: ImageAsset) {
        imageView.sd_setImageWithURL(imageAsset.url)
        view.bringSubviewToFront(imageView)
    }
    
    
    // MARK: Gif Asset
    
    private func addGifAsset(gifAsset: GifAsset) {
        playVideoUrl(gifAsset.url)
    }
    
    
    // MARK: Clear Media
    
    private func clearStageMedia() {
        delegate?.stage(self, willUpdateContentSize: CGSizeZero)
        UIView.animateWithDuration(Constants.contentSizeAnimationDuration) {
            self.view.layoutIfNeeded()
        }
        mainContentViewBottomConstraint.constant = 0
        delegate?.stage(self, didUpdateContentSize: CGSizeZero)
        
        currentStagedMedia = nil
    }
}
