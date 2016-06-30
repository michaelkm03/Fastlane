//
//  MediaContentView.swift
//  victorious
//
//  Created by Vincent Ho on 4/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

private struct Constants {
    static let blurRadius: CGFloat = 12
    static let fadeDuration: NSTimeInterval = 0.75
    static let backgroundFadeInDurationMultiplier = 0.75
    static let fadeOutDurationMultiplier = 1.25
    static let textPostLineSpacing: CGFloat = 2.0
    static let maxLineCount = 4
    static let textAlignment = NSTextAlignment.Center
    static let minimumScaleFactor: CGFloat = 0.8
    static let textPostPadding = 25
    static let defaultTextBackgroundColor = UIColor.blackColor()
    static let defaultTextColor = UIColor.whiteColor()
    static let defaultTextFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
}

/// Displays an image/video/GIF/Youtube video/text post upon setting the content property

class MediaContentView: UIView, ContentVideoPlayerCoordinatorDelegate, UIGestureRecognizerDelegate {
    
    private(set) var videoCoordinator: VContentVideoPlayerCoordinator?
    
    private let previewImageView = UIImageView()
    private let textPostLabel = UILabel()
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
    
    var dependencyManager: VDependencyManager?
    
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
        
        videoContainerView.frame = bounds
        videoContainerView.backgroundColor = .clearColor()
        addSubview(videoContainerView)
        
        textPostLabel.textAlignment = Constants.textAlignment
        textPostLabel.numberOfLines = Constants.maxLineCount
        textPostLabel.adjustsFontSizeToFitWidth = true
        textPostLabel.minimumScaleFactor = Constants.minimumScaleFactor
        addSubview(textPostLabel)
  
        addSubview(spinner)
        sendSubviewToBack(spinner)
        
        videoContainerView.alpha = 0.0
        previewImageView.alpha = 0.0
        textPostLabel.alpha = 0.0
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

        if (content.type == .text) {
            setUpTextLabel(for: content)
        }
        else {
            tearDownTextLabel()
        }
        
        setNeedsLayout()
    }
    
    private func displayNoContent() {
        tearDownPreviewImage()
        tearDownVideoPlayer()
        tearDownTextLabel()
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
                self.textPostLabel.alpha = 0
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
                self.textPostLabel.alpha = 1
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
        downloadedPreviewImage = nil
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
    
    // MARK: - Managing Text 
    
    private func setUpTextLabel(for content: ContentModel) {
        guard
            let text = content.text,
            let textPostDependency = dependencyManager?.textPostDependency
        else {
            return
        }
        
        textPostLabel.hidden = true //Hide while we set up the view for the next post
        textPostLabel.text = text
        textPostLabel.font = textPostDependency.textPostFont
        textPostLabel.textColor = textPostDependency.textPostColor
        
        if let url = textPostDependency.textPostBackgroundImageURL {
            setBackgroundBlur(withImageUrl: url, forContent: content) { [weak self] in
                guard
                    let currentContentID = self?.content?.id,
                    let hideAnimationDidFinish = self?.alphaHasAnimatedToZero
                where
                    currentContentID == content.id && hideAnimationDidFinish
                else {
                    return
                }
                
                self?.didSetupTextLabel()
            }
        }
        else {
            backgroundView?.image = nil
            backgroundView?.backgroundColor = Constants.defaultTextBackgroundColor
            didSetupTextLabel()
        }
    }
    
    private func tearDownTextLabel() {
        textPostLabel.hidden = true
        textPostLabel.text = ""
    }
    
    private func didSetupTextLabel() {
        spinner.stopAnimating()
        textPostLabel.hidden = false
        showContent()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewImageView.frame = bounds
        videoContainerView.frame = bounds
        textPostLabel.frame = CGRect(x: bounds.origin.x + CGFloat(Constants.textPostPadding), y: bounds.origin.y, width: bounds.width - CGFloat(2 * Constants.textPostPadding), height: bounds.height)
        
        // Warning: Dirty Hack
        // Background should extend a little beyond the original bounds,
        // so that the guassian blur doesn't introduce shadow at the edges
        var backgroundBounds = bounds
        backgroundBounds.origin.x -= 10
        backgroundBounds.origin.y -= 10
        backgroundBounds.size.height += 20
        backgroundBounds.size.width += 20
        
        backgroundView?.frame = backgroundBounds
        spinner.center = CGPoint(x: bounds.midX, y: bounds.midY)
        videoCoordinator?.layout(in: bounds)
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
            setBackgroundBlur(withImageUrl: imageURL, forContent: content)
        }
        else if
            let dataURL = content.assets.first?.resourceID,
            let imageURL = NSURL(string: dataURL)
            where content.type == .image
        {
            setBackgroundBlur(withImageUrl: imageURL, forContent: content)
        }
        else {
            backgroundView?.image = nil
        }
    }
    
    private func setBackgroundBlur(withImageUrl imageURL: NSURL, forContent content: ContentModel, completion: (()->())? = nil) {
        backgroundView?.applyBlurToImageURL(imageURL, withRadius: Constants.blurRadius) { [weak self] in
            guard let currentContentID = content.id where currentContentID == self?.content?.id else {
                return
            }
            self?.backgroundView?.alpha = 1
            completion?()
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

// MARK: - VDependency Manager extension

private extension VDependencyManager {
    var textPostDependency: VDependencyManager? {
        return childDependencyForKey("textPost")
    }
    
    var textPostFont: UIFont? {
        return fontForKey("font.textpost") ?? Constants.defaultTextFont
    }
    
    var textPostColor: UIColor {
        return colorForKey("color.textpost") ?? Constants.defaultTextColor
    }
    
    var textPostBackgroundImageURL: NSURL? {
        guard let urlString = stringForKey("backgroundImage.textpost") else {
            return nil
        }
        
        return NSURL(string: urlString)
    }
}
