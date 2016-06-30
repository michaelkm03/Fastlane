//
//  MediaContentView.swift
//  victorious
//
//  Created by Vincent Ho on 4/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// Displays an image/video/GIF/Youtube video upon setting the content property

class MediaContentView: UIView, ContentVideoPlayerCoordinatorDelegate, UIGestureRecognizerDelegate {
    private struct Constants {
        static let blurRadius: CGFloat = 12
        static let fadeDuration: NSTimeInterval = 0.75
        static let backgroundFadeInDurationMultiplier = 0.75
        static let fadeOutDurationMultiplier = 1.25
    }
    
    private(set) var videoCoordinator: VContentVideoPlayerCoordinator?
    
    private let previewImageView = UIImageView()
    private let videoContainerView = VPassthroughContainerView()
    private var backgroundView: UIImageView?
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    private var alphaHasAnimatedToZero = false
    private var downloadedPreviewImage: UIImage?
    
    private lazy var singleTapRecognizer: UITapGestureRecognizer = {
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onContentTap))
        singleTapRecognizer.numberOfTapsRequired = 1
        singleTapRecognizer.delegate = self
        
        return singleTapRecognizer
    }()
    
    // MARK: - Initializing
    
    init(showsBackground: Bool = true) {
        self.showsBackground = showsBackground
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        clipsToBounds = true
        backgroundColor = .clearColor()
        
        configureBackground()
        
        addSubview(previewImageView)
        
        videoContainerView.backgroundColor = .clearColor()
        addSubview(videoContainerView)
        
        addSubview(spinner)
        sendSubviewToBack(spinner)
        
        videoContainerView.alpha = 0.0
        previewImageView.alpha = 0.0
        backgroundView?.alpha = 0.0
        
        addGestureRecognizer(singleTapRecognizer)
    }
    
    // MARK: - Configuration
    
    /// Determines whether we want video control for video content. E.g.: Stage disables video control for video content
    var allowsVideoControls = true
    
    /// Whether or not the view performs an animated transition whenever new content is displayed.
    var animatesBetweenContent = true
    
    /// Whether or not the blurred preview image background is shown behind the media.
    var showsBackground = true {
        didSet {
            if showsBackground != oldValue {
                configureBackground()
            }
        }
    }
    
    private func configureBackground() {
        previewImageView.contentMode = showsBackground ? .ScaleAspectFit : .ScaleAspectFill
        
        if showsBackground {
            let backgroundView = UIImageView()
            self.backgroundView = backgroundView
            backgroundView.contentMode = .ScaleAspectFill
            insertSubview(backgroundView, atIndex: 0)
        }
        else {
            backgroundView?.removeFromSuperview()
            backgroundView = nil
        }
    }
    
    // MARK: - Managing content
    
    var content: ContentModel? {
        didSet {
            guard content?.id != oldValue?.id || content?.id == nil else {
                return
            }
            
            if let content = content {
                displayContent(content)
            }
            else {
                displayNoContent()
            }
            
            setNeedsLayout()
        }
    }
    
    private func displayContent(content: ContentModel) {
        spinner.startAnimating()
        hideContent(animated: animatesBetweenContent)
        
        // Set up image view if content is image
        let minWidth = frame.size.width
        
        if content.type.displaysAsImage, let previewImageURL = content.previewImageURL(ofMinimumWidth: minWidth) ?? NSURL(v_string: content.assets.first?.resourceID) {
            setUpPreviewImage(from: previewImageURL)
        }
        else {
            tearDownPreviewImage()
        }
        
        // Set up video view if content is video
        if content.type.displaysAsVideo {
            setUpVideoPlayer(for: content)
        }
        else {
            tearDownVideoPlayer()
        }
    }
    
    private func displayNoContent() {
        tearDownPreviewImage()
        tearDownVideoPlayer()
    }
    
    func hideContent(animated animated: Bool = true) {
        videoCoordinator?.pauseVideo()
        
        let animationDuration = animated ? Constants.fadeDuration * Constants.fadeOutDurationMultiplier : 0
        
        UIView.animateWithDuration(
            animationDuration,
            delay: 0,
            options: [.BeginFromCurrentState, .AllowUserInteraction],
            animations: {
                self.videoContainerView.alpha = 0
                self.previewImageView.alpha = 0
                self.backgroundView?.alpha = 0
            },
            completion: { [weak self] _ in
                self?.alphaHasAnimatedToZero = true
                self?.updatePreviewImageIfReady()
            }
        )
    }
    
    func showContent(animated animated: Bool = true) {
        let animationDuration = animated ? Constants.fadeDuration : 0
        
        // Animate the backgroundView faster
        UIView.animateWithDuration(
            animationDuration * Constants.backgroundFadeInDurationMultiplier,
            delay: 0,
            options: [.AllowUserInteraction],
            animations: {
                self.backgroundView?.alpha = 1
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
            completion: { [weak self] completed in
                self?.videoCoordinator?.playVideo()
            }
        )
    }
    
    // MARK: - Managing preview image
    
    private func setUpPreviewImage(from url: NSURL) {
        previewImageView.hidden = false
        previewImageView.sd_setImageWithURL(
            url,
            placeholderImage: previewImageView.image, // Leave the image as is, since we want to wait until animation has finished before setting the image.
            options: .AvoidAutoSetImage
        ) { [weak self] image, _, _, _ in
            self?.downloadedPreviewImage = image
            self?.updatePreviewImageIfReady()
        }
    }
    
    private func tearDownPreviewImage() {
        previewImageView.hidden = true
    }
    
    // MARK: - Managing video
    
    private func setUpVideoPlayer(for content: ContentModel) {
        videoContainerView.hidden = false
        videoCoordinator?.tearDown()
        videoCoordinator = VContentVideoPlayerCoordinator(content: content)
        videoCoordinator?.setupVideoPlayer(in: videoContainerView)
        
        if allowsVideoControls {
            videoCoordinator?.setupToolbar(in: self, initallyVisible: false)
        }
        
        videoCoordinator?.loadVideo()
        videoCoordinator?.delegate = self
    }
    
    private func tearDownVideoPlayer() {
        videoContainerView.hidden = true
        videoCoordinator?.tearDown()
        videoCoordinator = nil
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewImageView.frame = bounds
        videoContainerView.frame = bounds
        backgroundView?.frame = bounds
        spinner.center = CGPoint(x: bounds.midX, y: bounds.midY)
        videoCoordinator?.layout(in: videoContainerView.bounds, withContentFill: !showsBackground)
    }
    
    private func updatePreviewImageIfReady() {
        guard
            let content = content where
            downloadedPreviewImage != nil && alphaHasAnimatedToZero
        else {
            return
        }
        spinner.stopAnimating()
        previewImageView.image = downloadedPreviewImage
        downloadedPreviewImage = nil
        alphaHasAnimatedToZero = false
        showContent(animated: animatesBetweenContent)
        
        let minWidth = UIScreen.mainScreen().bounds.size.width
        if let imageURL = content.previewImageURL(ofMinimumWidth: minWidth) {
            setBackgroundBlur(withImageUrl: imageURL)
        }
        else if
            let dataURL = content.assets.first?.resourceID,
            let imageURL = NSURL(string: dataURL)
            where content.type == .image
        {
            setBackgroundBlur(withImageUrl: imageURL)
        }
        else {
            backgroundView?.image = nil
        }
    }
    
    private func setBackgroundBlur(withImageUrl imageURL: NSURL) {
        backgroundView?.applyBlurToImageURL(imageURL, withRadius: Constants.blurRadius) { [weak self] in
            self?.backgroundView?.alpha = 1
        }
    }

    // MARK: - Actions

    func onContentTap() {
        if allowsVideoControls && content?.type == .video {
            videoCoordinator?.toggleToolbarVisibility(true)
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // This allows the owner of the view to add its own tap gesture recognizer.
        return true
    }
    
    // MARK: - ContentVideoPlayerCoordinatorDelegate
    
    func coordinatorDidBecomeReady() {
        downloadedPreviewImage = UIImage() // FUTURE: Set this to the preview image of the video
        updatePreviewImageIfReady()
    }
}
