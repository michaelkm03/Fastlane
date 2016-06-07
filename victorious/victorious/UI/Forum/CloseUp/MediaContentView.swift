
//
//  MediaContentView.swift
//  victorious
//
//  Created by Vincent Ho on 4/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// Displays an image/video/GIF/Youtube video upon setting the content property
class MediaContentView: UIView {
    private static let fadeInOutDuration: NSTimeInterval = 1.0

    let previewImageView = UIImageView()
    let videoContainerView = VPassthroughContainerView()
    
    private(set) var videoCoordinator: VContentVideoPlayerCoordinator?
    private(set) var content: ContentModel?
    
    private var singleTapRecognizer: UITapGestureRecognizer!
    
    /// Determines whether we want video control for video content. E.g.: Stage disables video control for video content
    private var shouldShowToolBarForVideo: Bool = true
    
    private var spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    override func awakeFromNib() {
        addSubview(spinner)
        sendSubviewToBack(spinner)
        v_addCenterToParentContraintsToSubview(spinner)
        
        singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onContentTap))
        singleTapRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(singleTapRecognizer)
        
        backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.15)
        
        previewImageView.contentMode = .ScaleAspectFit
        addSubview(previewImageView)
        v_addFitToParentConstraintsToSubview(previewImageView)
        
        videoContainerView.frame = bounds
        videoContainerView.backgroundColor = .clearColor()
        addSubview(videoContainerView)
        v_addFitToParentConstraintsToSubview(videoContainerView)
        
        videoContainerView.alpha = 0.0
        previewImageView.alpha = 0.0
    }
    
    func updateContent(content: ContentModel, isVideoToolBarAllowed: Bool = true) {
        spinner.startAnimating()
        animateContentToAlpha(0.0)
        self.content = content
        shouldShowToolBarForVideo = isVideoToolBarAllowed && content.type == .video
        
        let minWidth = UIScreen.mainScreen().bounds.size.width
        
        // Set up image view if content is image
        if content.type.displaysAsImage,
            let previewImageURL = content.previewImageURL(ofMinimumWidth: minWidth) ?? NSURL(v_string: content.assetModels.first?.resourceID) {
            previewImageView.hidden = false
            previewImageView.sd_setImageWithURL(previewImageURL) { [weak self] _ in
                self?.finishedLoadingContent()
            }
        } else {
            previewImageView.hidden = true
        }
        
        // Set up video view if content is video
        if content.type.displaysAsVideo {
            videoContainerView.hidden = false
            videoCoordinator = VContentVideoPlayerCoordinator(content: content)
            videoCoordinator?.setupVideoPlayer(in: videoContainerView)
            videoCoordinator?.setupToolbar(in: self, initallyVisible: false)
            videoCoordinator?.loadVideo() { [weak self] in
                self?.finishedLoadingContent()
            }
        } else {
            videoContainerView.hidden = true
        }
    }
    
    private func finishedLoadingContent() {
        dispatch_after(5, {
            self.spinner.stopAnimating()
            self.animateContentToAlpha(1.0)
        })
    }
    
    private func animateContentToAlpha(alpha: CGFloat, animated: Bool = true) {
        let animationDuration = animated ? MediaContentView.fadeInOutDuration : NSTimeInterval(0)
        UIView.animateWithDuration(animationDuration, animations: {
            self.videoContainerView.alpha = alpha
            self.previewImageView.alpha = alpha
        })
    }
    
    // MARK: - Actions
    
    func onContentTap() {
        if shouldShowToolBarForVideo {
            videoCoordinator?.toggleToolbarVisibility(true)
        }
    }
}
