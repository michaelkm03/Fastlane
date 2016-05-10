
//
//  MediaContentView.swift
//  victorious
//
//  Created by Vincent Ho on 4/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

private let kMinimumPlayButtonInset: CGFloat = 14

/// Displays an image/video/GIF/Youtube video upon setting the content property
class MediaContentView: UIView {
    var previewImageView: UIImageView = UIImageView()
    var videoContainerView: VPassthroughContainerView = VPassthroughContainerView()
    private(set) var videoCoordinator: VideoPlayerCoordinator!
    
    private var singleTapRecognizer: UITapGestureRecognizer!
    private var doubleTapRecognizer: UITapGestureRecognizer!
    
    override func awakeFromNib() {
        singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onContentTap))
        singleTapRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(singleTapRecognizer)
        doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onContentDoubleTap))
        doubleTapRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapRecognizer)
        
        videoContainerView.backgroundColor = .blackColor()
        
        backgroundColor = .clearColor()
        previewImageView.contentMode = UIViewContentMode.ScaleAspectFill
        addSubview(previewImageView)
        v_addFitToParentConstraintsToSubview(previewImageView)
    }
    
    var content: VContent? {
        didSet {
            guard let content = content else {
                fatalError("Content cannot be nil")
            }
            guard let videoCoordinator = VideoPlayerCoordinator(content: content) else {
                return
            }
            self.videoCoordinator = videoCoordinator
            
            let minWidth = CGRectGetWidth(UIScreen.mainScreen().bounds)
            
            if let preview = content.previewImageWithMinimumWidth(minWidth),
                let previewRemoteURL = preview.imageURL,
                let previewImageURL = NSURL(string: previewRemoteURL) {
                previewImageView.sd_setImageWithURL(previewImageURL)
            }
            setupForContent(content)
            if let contentType = content.contentType() where contentType != ContentType.image {
                setupVideoContainer()
                videoCoordinator.setupVideoPlayer(in: videoContainerView)
                videoCoordinator.setupToolbar(in: self, initallyVisible: false)
                videoCoordinator.loadVideo()
            }
        }
    }
    
    private func setupForContent(content: VContent) {
        guard let contentType = content.contentType() else {
            // default to image type
            videoContainerView.hidden = true
            previewImageView.hidden = false
            return
        }
        switch contentType {
        case .image:
            videoContainerView.hidden = true
            previewImageView.hidden = false
        case .video:
            videoContainerView.hidden = false
            previewImageView.hidden = true
        case .gif:
            videoContainerView.hidden = false
            previewImageView.hidden = true
        }
    }
    
    private func setupVideoContainer() {
        videoContainerView.frame = bounds
        addSubview(videoContainerView)
        v_addFitToParentConstraintsToSubview(videoContainerView)
    }
    
    private func shouldShowToolbar() -> Bool {
        guard let contentType = content?.contentType() else {
            return false
        }
        return contentType == .video
    }
    
    // MARK: - Actions
    
    func onContentTap() {
        if !shouldShowToolbar() {
            return
        }
        videoCoordinator.toggleToolbarVisibility(true)
    }
    
    func onContentDoubleTap() {
        
    }
    
    // MARK: - Helpers
    
    private func shouldReplay() -> Bool {
        guard let contentType = content?.contentType() else {
            return false
        }
        return contentType == .gif
    }
}
