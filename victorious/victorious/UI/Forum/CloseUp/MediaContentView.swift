
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
    
    override func awakeFromNib() {
        singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onContentTap))
        singleTapRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(singleTapRecognizer)
        
        videoContainerView.backgroundColor = .blackColor()
        
        backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.15)
        previewImageView.contentMode = .ScaleAspectFill
        addSubview(previewImageView)
        v_addFitToParentConstraintsToSubview(previewImageView)
    }
    
    func updateContent(content: ContentModel) {
        self.content = content
    }
    
    private(set) var content: ContentModel? {
        didSet {
            guard let content = content else {
                assertionFailure("Content cannot be nil")
                return
            }
            guard let videoCoordinator = VContentVideoPlayerCoordinator(content: content) else {
                return
            }
            self.videoCoordinator = videoCoordinator
            
            let minWidth = UIScreen.mainScreen().bounds.size.width
            
            if let previewImageURL = content.previewImageURL(ofMinimumWidth: minWidth) {
                previewImageView.sd_setImageWithURL(previewImageURL)
            }
            setupForContent(content)
            if content.type.displaysAsVideo {
                setupVideoContainer()
                videoCoordinator.setupVideoPlayer(in: videoContainerView)
                videoCoordinator.setupToolbar(in: self, initallyVisible: false)
                videoCoordinator.loadVideo()
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
    
    private func shouldShowToolbar() -> Bool {
        return content?.type == .video
    }
    
    // MARK: - Actions
    
    func onContentTap() {
        if !shouldShowToolbar() {
            return
        }
        videoCoordinator?.toggleToolbarVisibility(true)
    }
}
