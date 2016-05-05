
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
    
    var content: CloseUpContent? {
        didSet {
            guard let content = content else {
                fatalError("Content cannot be nil")
            }
            videoCoordinator = VideoPlayerCoordinator(content: content)
            previewImageView.sd_setImageWithURL(content.previewImageURL)
            setupForContentType(content.contentType)
            if content.contentType != .Image {
                setupVideoContainer()
                videoCoordinator.setupVideoPlayer(in: videoContainerView)
                videoCoordinator.setupToolbar(in: self, initallyVisible: false)
                videoCoordinator.loadVideo()
            }
        }
    }
    
    private func setupForContentType(contentType: CloseUpContentType) {
        switch contentType {
        case .Image:
            videoContainerView.hidden = true
            previewImageView.hidden = false
        case .Video:
            videoContainerView.hidden = false
            previewImageView.hidden = true
        case .GIF:
            videoContainerView.hidden = false
            previewImageView.hidden = true
        case .Youtube:
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
        let currentContentType = content?.contentType
        return currentContentType == .Video || currentContentType == .Youtube
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
        return content?.contentType == .GIF
    }
}
