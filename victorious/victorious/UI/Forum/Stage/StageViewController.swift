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
    private var videoPlayer: VVideoView?
    
    private var currentStagedMedia: Stageable?
    
    private var dependencyManager: VDependencyManager!
    
    class func new(dependencyManager dependencyManager: VDependencyManager) -> StageViewController {
        //TODO: Load from storyboard
        let stageVC = StageViewController()
        stageVC.dependencyManager = dependencyManager
        return stageVC
    }
    
    
    //MARK: - Stage
    
    weak var delegate: StageDelegate?
    
    func startPlayingMedia(media: Stageable) {
        currentStagedMedia = media

        switch media {
        case let videoAsset as VideoAsset:
            addVideoAsset(videoAsset)
        case let imageAsset as ImageAsset:
            addImageAsset(imageAsset)
            
        // case Gif?
            
        // case Empty?
//        case let emptyAsset as EmptyAsset:
//            print("will remove current staged media and possibly hide the stage")
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
        print("Video player did reach end! Clearing out stage.")
        clearStageMedia()
    }
    
    
    // MARK: - Private
    
    // TODO: get size of content for setting `mainContentViewBottomConstraint.constant`
    
    private func addVideoAsset(videoAsset: VideoAsset) {
        print("will add video to stage")
        guard let resourceLocation = videoAsset.resourceLocation, let videoUrl = NSURL(string: resourceLocation) else {
            print("No resource to load at -> \(videoAsset.resourceLocation)")
            return
        }
        
        let videoItem = VVideoPlayerItem(URL: videoUrl)
        
        if videoPlayer == nil {
            videoPlayer = setupVideoView(videoContainerView)
        }
        videoPlayer?.setItem(videoItem)
        
        videoPlayer?.playFromStart()
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
    
    private func addImageAsset(imageAsset: ImageAsset) {
        print("will add image to stage")
        imageView.sd_setImageWithURL(imageAsset.url)
    }
    
    private func clearStageMedia() {
        delegate?.stage(self, willUpdateContentSize: CGSizeZero)
        UIView.animateWithDuration(Constants.contentSizeAnimationDuration) { self.view.layoutIfNeeded() }
        mainContentViewBottomConstraint.constant = 0
        delegate?.stage(self, didUpdateContentSize: CGSizeZero)
        
        currentStagedMedia = nil
    }
}
