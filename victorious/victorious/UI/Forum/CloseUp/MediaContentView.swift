
//
//  MediaContentView.swift
//  victorious
//
//  Created by Vincent Ho on 4/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// Displays an image/video/GIF/Youtube video upon setting the content property
class MediaContentView: UIView, ContentVideoPlayerCoordinatorDelegate {
    private let previewImageView = UIImageView()
    private let videoContainerView = VPassthroughContainerView()
    private let backgroundView = UIImageView()
    private static let fadeInOutDuration: NSTimeInterval = 1.0
    
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
        
        self.clipsToBounds = true
        backgroundColor = .clearColor()
        
        previewImageView.contentMode = .ScaleAspectFit
        addSubview(previewImageView)
        v_addFitToParentConstraintsToSubview(previewImageView)
        
        videoContainerView.frame = bounds
        videoContainerView.backgroundColor = .clearColor()
        addSubview(videoContainerView)
        v_addFitToParentConstraintsToSubview(videoContainerView)
        
        videoContainerView.alpha = 0.0
        previewImageView.alpha = 0.0
        backgroundView.contentMode = .ScaleAspectFill
        insertSubview(backgroundView, atIndex: 0) //Insert behind all other views
        v_addFitToParentConstraintsToSubview(backgroundView)
    }
    
    func updateContent(content: ContentModel, isVideoToolBarAllowed: Bool = true) {
        spinner.startAnimating()
        animateContentToAlpha(0.0)
        self.content = content
        shouldShowToolBarForVideo = isVideoToolBarAllowed && content.type == .video
        
        // Set up image view if content is image
        let minWidth = UIScreen.mainScreen().bounds.size.width
        if content.type.displaysAsImage,
            let previewImageURL = content.previewImageURL(ofMinimumWidth: minWidth) ?? NSURL(v_string: content.assetModels.first?.resourceID) {
            previewImageView.hidden = false
            previewImageView.sd_setImageWithURL(previewImageURL) { [weak self] _ in
                self?.didFinishLoadingContent()
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
            videoCoordinator?.loadVideo()
            videoCoordinator?.delegate = self
        } else {
            videoContainerView.hidden = true
        }
    }
    
    private func animateContentToAlpha(alpha: CGFloat, animated: Bool = true) {
        let animationDuration = animated ? MediaContentView.fadeInOutDuration : NSTimeInterval(0)
        UIView.animateWithDuration(animationDuration, animations: {
            self.videoContainerView.alpha = alpha
            self.previewImageView.alpha = alpha
        })
    }
    
    ///Called after any asynchronous content fetch is complete
    func didFinishLoadingContent() {
        spinner.stopAnimating()
        animateContentToAlpha(1.0)

        guard let content = self.content else {
            return
        }
        
        let minWidth = UIScreen.mainScreen().bounds.size.width
        //Add blurred background
        if let imageURL = content.previewImageURL(ofMinimumWidth: minWidth) ?? NSURL(v_string: content.assetModels.first?.resourceID) {
            backgroundView.applyBlurToImageURL(imageURL, withRadius: 12.0){ [weak self] in
                self?.backgroundView.alpha = 1.0
            }
        }
    }
    
    // MARK: - Actions
    
    func onContentTap() {
        if shouldShowToolBarForVideo {
            videoCoordinator?.toggleToolbarVisibility(true)
        }
    }
    
    //MARK: - ContentVideoPlayerCoordinatorDelegate
    
    func coordinatorDidBecomeReady() {
        didFinishLoadingContent()
    }
}
