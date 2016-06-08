
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
    
    private var imageToSet: UIImage?
    private var animatedToZero = false
    
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
        
        clipsToBounds = true
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
    
    func hideContent() {
        animateContentToZero()
    }
    
    func updateContent(content: ContentModel, isVideoToolBarAllowed: Bool = true) {
        spinner.startAnimating()
        self.content = content
        shouldShowToolBarForVideo = isVideoToolBarAllowed && content.type == .video
        
        animateContentToZero()
        // Set up image view if content is image
        let minWidth = UIScreen.mainScreen().bounds.size.width
        if content.type.displaysAsImage,
            let previewImageURL = content.previewImageURL(ofMinimumWidth: minWidth) ?? NSURL(v_string: content.assetModels.first?.resourceID) {
            previewImageView.hidden = false
            previewImageView.sd_setImageWithURL(
                previewImageURL,
                placeholderImage: previewImageView.image, // Leave the image as is
                options: .AvoidAutoSetImage) { [weak self] image, _, _, _ in
                    self?.imageToSet = image
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
    
    private func animateContentToZero(animated: Bool = true) {
        let animationDuration = animated ? MediaContentView.fadeInOutDuration : NSTimeInterval(0)
        UIView.animateWithDuration(
            animationDuration,
            delay: 0,
            options: [.BeginFromCurrentState, .AllowUserInteraction],
            animations: {
                self.videoContainerView.alpha = 0
                self.previewImageView.alpha = 0
                self.backgroundView.alpha = 0
            },
            completion: { [weak self] _ in
                self?.animatedToZero = true
                self?.setImageIfAvailable()
            }
        )
    }
    
    private func setImageIfAvailable() {
        if imageToSet != nil && animatedToZero {
            previewImageView.image = imageToSet
            imageToSet = nil
            animatedToZero = false
            animateContentToVisible()
            
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
    }
    
    private func animateContentToVisible(animated: Bool = true) {
        let animationDuration = animated ? MediaContentView.fadeInOutDuration : NSTimeInterval(0)
        
        // Animate the backgroundView faster
        UIView.animateWithDuration(
            animationDuration/2,
            delay: 0,
            options: [.AllowUserInteraction],
            animations: {
                self.backgroundView.alpha = 1
            },
            completion: nil
        )
        
        UIView.animateWithDuration(
            animationDuration,
            delay: 0,
            options: [.AllowUserInteraction],
            animations: {
                self.videoContainerView.alpha = 1
                self.previewImageView.alpha = 1
            },
            completion: nil
        )
    }
    
    ///Called after any asynchronous content fetch is complete
    func didFinishLoadingContent() {
        spinner.stopAnimating()
        setImageIfAvailable()
    }
    
    // MARK: - Actions
    
    func onContentTap() {
        if shouldShowToolBarForVideo {
            videoCoordinator?.toggleToolbarVisibility(true)
        }
    }
    
    //MARK: - ContentVideoPlayerCoordinatorDelegate
    
    func coordinatorDidBecomeReady() {
        imageToSet = UIImage() // Hack to show the video coordinator
        didFinishLoadingContent()
    }
}
