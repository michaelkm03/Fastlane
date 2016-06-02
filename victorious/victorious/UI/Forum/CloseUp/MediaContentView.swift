
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
    let previewImageView = UIImageView()
    let videoContainerView = VPassthroughContainerView()
    private(set) var videoCoordinator: VContentVideoPlayerCoordinator?
    
    private var singleTapRecognizer: UITapGestureRecognizer!
    
    /// Determines whether we want video control for video content. E.g.: Stage disables video control for video content
    private var shouldShowToolBarForVideo: Bool = true
    
    override func awakeFromNib() {
        singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onContentTap))
        singleTapRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(singleTapRecognizer)
        
        videoContainerView.backgroundColor = .blackColor()
        
        backgroundColor = .clearColor()
        previewImageView.contentMode = .ScaleAspectFill
        addSubview(previewImageView)
        v_addFitToParentConstraintsToSubview(previewImageView)
    }
    
    func updateContent(content: ContentModel, isVideoToolBarAllowed: Bool = true) {
        self.content = content
        self.shouldShowToolBarForVideo = isVideoToolBarAllowed && content.type == .video
    }
    
    private(set) var content: ContentModel? {
        didSet {
            guard let content = content else {
                assertionFailure("Content cannot be nil")
                return
            }
            
            let minWidth = UIScreen.mainScreen().bounds.size.width
            
            if let previewImageURL = content.previewImageURL(ofMinimumWidth: minWidth) ?? NSURL(v_string: content.assetModels.first?.resourceID) {
                previewImageView.sd_setImageWithURL(previewImageURL)
            }
            setupForContent(content)
            if content.type.displaysAsVideo {
                self.videoCoordinator = VContentVideoPlayerCoordinator(content: content)
                setupVideoContainer()
                videoCoordinator?.setupVideoPlayer(in: videoContainerView)
                videoCoordinator?.setupToolbar(in: self, initallyVisible: false)
                videoCoordinator?.loadVideo()
            }
        }
    }
    
    private func setupForContent(content: ContentModel) {
        videoContainerView.hidden = content.type.displaysAsVideo != true
        previewImageView.hidden = content.type.displaysAsImage != true
    }
    
    private func setupVideoContainer() {
        videoContainerView.frame = bounds
        addSubview(videoContainerView)
        v_addFitToParentConstraintsToSubview(videoContainerView)
    }
    
    
    // MARK: - Actions
    
    func onContentTap() {
        if shouldShowToolBarForVideo {
            videoCoordinator?.toggleToolbarVisibility(true)
        }
    }
}
