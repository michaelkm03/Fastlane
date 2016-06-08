
//
//  MediaContentView.swift
//  victorious
//
//  Created by Vincent Ho on 4/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// Displays an image/video/GIF/Youtube video upon setting the content property
class MediaContentView: UIView, VContentVideoPlayerCoordinatorDelegate {
    private let previewImageView = UIImageView()
    private let videoContainerView = VPassthroughContainerView()
    private let backgroundView = UIImageView()
    
    private(set) var videoCoordinator: VContentVideoPlayerCoordinator?
    private(set) var content: ContentModel?
    
    private var singleTapRecognizer: UITapGestureRecognizer!
    
    /// Determines whether we want video control for video content. E.g.: Stage disables video control for video content
    private var shouldShowToolBarForVideo: Bool = true
    
    override func awakeFromNib() {
        singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onContentTap))
        singleTapRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(singleTapRecognizer)
        
        backgroundColor = .clearColor()
        
        previewImageView.contentMode = .ScaleAspectFit
        addSubview(previewImageView)
        v_addFitToParentConstraintsToSubview(previewImageView)
        
        videoContainerView.frame = bounds
        videoContainerView.backgroundColor = .blackColor()
        addSubview(videoContainerView)
        v_addFitToParentConstraintsToSubview(videoContainerView)
        
        backgroundView.contentMode = .ScaleAspectFill
        backgroundView.clipsToBounds = true //Required because Scale Aspect Fill tends to overflow outside bounds
        self.insertSubview(backgroundView, atIndex: 0) //Insert behind all other views
        self.v_addFitToParentConstraintsToSubview(backgroundView)
    }
    
    func updateContent(content: ContentModel, isVideoToolBarAllowed: Bool = true) {
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
    
    ///Called after any asynchronous content fetch is complete
    func didFinishLoadingContent() {
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
    
    //MARK: - VVideoCoordinatorDelegate
    func coordinatorDidBecomeReady() {
        self.didFinishLoadingContent()
    }
}
