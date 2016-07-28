//
//  MediaContentView.swift
//  victorious
//
//  Created by Vincent Ho on 4/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

protocol MediaContentViewDelegate: class {
    /// Tells the delegate that a particular content is loaded.
    func didFinishLoadingContent(content: ContentModel)

//    func failedToLoadContent(content: ContentModel, error: NSError?)
}

enum FillMode {
    case fill
    case fit
}

struct MediaContentViewConfiguration {
    /// Whether or not the blurred preview image background is shown behind the media.
    let showsBlurredBackground: Bool
    
    /// Determines whether we want video control for video content. E.g.: Stage disables video control for video content
    let allowsVideoControls: Bool
    
    let fillMode: FillMode
}

/// Displays an image/video/GIF/Youtube video/text post upon setting the content property.
class MediaContentView: UIView, ContentVideoPlayerCoordinatorDelegate, UIGestureRecognizerDelegate, Presentable {

    let dependencyManager: VDependencyManager
    let content: ContentModel

    weak var delegate: MediaContentViewDelegate?

    // MARK: - Private

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
        static let defaultTextColor = UIColor.whiteColor()
        static let defaultTextFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    }

    private(set) var videoCoordinator: VContentVideoPlayerCoordinator?
    private var backgroundView: UIImageView?
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    private var downloadedPreviewImage: UIImage?

    private lazy var previewImageView = {
        return UIImageView()
    }()

    private lazy var textPostLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = Constants.textAlignment
        label.numberOfLines = Constants.maxLineCount
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = Constants.minimumScaleFactor
        return label
    }()

    private lazy var videoContainerView = {
        return VPassthroughContainerView()
    }()
    
    private lazy var singleTapRecognizer: UITapGestureRecognizer = {
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onContentTap))
        singleTapRecognizer.numberOfTapsRequired = 1
        singleTapRecognizer.delegate = self
        return singleTapRecognizer
    }()
    
    // MARK: - Initializing

    /// Sets up the content view with a zero frame. Use this initializer if created from code.
    /// showsBlurredBackground decides if the system blur is applied to the background view.
    init(
        content: ContentModel,
        dependencyManager: VDependencyManager,
        configuration: MediaContentViewConfiguration
    ) {
        self.content = content
        self.dependencyManager = dependencyManager
        self.configuration = configuration
        
        super.init(frame: CGRect.zero)
        
        setup()
        configureBackground()
        // TODO: Load content
    }
    
    required init?(coder: NSCoder) {
        fatalError("Cannot create MCV from a storyboard.")
    }
    
    private func setup() {
        clipsToBounds = true
        backgroundColor = .clearColor()
        
        configureBackground()
        
        addSubview(previewImageView)
        
        videoContainerView.backgroundColor = .clearColor()
        addSubview(videoContainerView)
        
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
    
    private var configuration: MediaContentViewConfiguration
    
    private func configureBackground() {
        previewImageView.contentMode = (configuration.fillMode == .fit) ? .ScaleAspectFit : .ScaleAspectFill
        
        let backgroundView = UIImageView()
        self.backgroundView = backgroundView
        backgroundView.contentMode = .ScaleAspectFill
        insertSubview(backgroundView, atIndex: 0)

        if !configuration.showsBlurredBackground {
            backgroundView.image = nil
        }
    }

    // MARK: - Presentable

    func willBePresented() {
        // TODO: play
    }

    func willBeDismissed() {
        // TODO: pause
    }

    // MARK: - Managing content

    /// Can we seek ahead into the item with the current seekAheadTime stored in the content.
    var seekableWithinBounds: Bool {
        if content.type != .video {
            return true
        }

        // Duration will be NaN if the item hasn't loaded yet.
        guard let videoCoordinator = videoCoordinator where !videoCoordinator.duration.isNaN else {
            return false
        }

        return (videoCoordinator.duration >= content.seekAheadTime())
    }

    func hideContent(animated animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
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
            completion: { didFinish in
                completion?(didFinish)
            }
        )
    }
    
    func showContent(animated animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
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
            completion: { didFinish in
                completion?(didFinish)
            }
        )
    }

    private func displayContent(content: ContentModel) {
        spinner.startAnimating()
        hideContent(animated: true) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            // Set up image view if content is image
            let minWidth = strongSelf.frame.size.width
            
            if content.type.displaysAsImage, let imageAsset = content.previewImage(ofMinimumWidth: minWidth) {
                strongSelf.setUpPreviewImage(from: imageAsset)
            }
            else if content.type.displaysAsVideo {
                strongSelf.setUpVideoPlayer(for: content)
            }
            else if content.type == .text {
                strongSelf.setUpTextLabel()
            }
        }
    }
    
    // MARK: - Managing preview image
    
    private func setUpPreviewImage(from imageAsset: ImageAssetModel) {
        //Images don't need a video player and a text label
        tearDownVideoPlayer()
        tearDownTextLabel()
        
        previewImageView.hidden = false
        
        switch imageAsset.imageSource {
            case .remote(let url):
                previewImageView.sd_setImageWithURL(
                    url,
                    placeholderImage: previewImageView.image, // Leave the image as is, since we want to wait until animation has finished before setting the image.
                    options: .AvoidAutoSetImage
                ) { [weak self] image, _, _, _ in
                    self?.downloadedPreviewImage = image
                    self?.updatePreviewImageIfReady()
                }
            case .local(let image):
                downloadedPreviewImage = image
                updatePreviewImageIfReady()
        }        
    }
    
    private func tearDownPreviewImage() {
        previewImageView.hidden = true
        downloadedPreviewImage = nil
    }
    
    // MARK: - Managing video
    
    private func setUpVideoPlayer(for content: ContentModel) {
        tearDownTextLabel()
        tearDownPreviewImage()
        
        videoContainerView.hidden = false
        videoCoordinator?.tearDown()
        videoCoordinator = VContentVideoPlayerCoordinator(content: content)
        videoCoordinator?.setupVideoPlayer(in: videoContainerView)
        
        if configuration.allowsVideoControls {
            videoCoordinator?.setupToolbar(in: self, initallyVisible: false)
        }
        
        videoCoordinator?.loadVideo()
        videoCoordinator?.delegate = self
        
        setNeedsLayout()
    }
    
    private func tearDownVideoPlayer() {
        videoContainerView.hidden = true
        videoCoordinator?.tearDown()
        videoCoordinator = nil
    }
    
    func playVideo() {
        videoCoordinator?.playVideo()
    }
    
    func pauseVideo() {
        videoCoordinator?.pauseVideo()
    }
    
    // MARK: - Managing Text 
    
    private func setUpTextLabel() {
        tearDownPreviewImage()
        tearDownVideoPlayer()
        
        let textPostDependency = self.dependencyManager.textPostDependency
        textPostLabel.font = textPostDependency?.textPostFont ?? Constants.defaultTextFont
        textPostLabel.textColor = textPostDependency?.textPostColor ?? Constants.defaultTextColor
        
        textPostLabel.hidden = true //Hide while we set up the view for the next post

        guard let url = textPostDependency?.textPostBackgroundImageURL else {
            return
        }

        if configuration.showsBlurredBackground {
            let imageAsset = ImageAsset(url: url, size: frame.size)
            setBackgroundBlur(withImageAsset: imageAsset, forContent: content) { [weak self] in
                guard let currentContentID = self?.content.id where currentContentID == self?.content.id else {
                    return
                }
                guard let text = self?.content.text else {
                    return
                }
                self?.renderText(text)
            }
        }
        else {
            backgroundView?.sd_setImageWithURL(url, completed: { [weak self] (_, _, _, _) in
                guard let text = self?.content.text else {
                    return
                }
                self?.renderText(text)
            })
        }
    }
    
    private func tearDownTextLabel() {
        textPostLabel.hidden = true
        textPostLabel.text = ""
    }
    
    private func renderText(text: String?) {
        guard let text = text else {
            return
        }
        textPostLabel.text = text
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
        backgroundView?.frame = computeBackgroundBounds()
        spinner.center = CGPoint(x: bounds.midX, y: bounds.midY)
        videoCoordinator?.layout(in: videoContainerView.bounds, with: configuration.fillMode)
    }
    
    private func updatePreviewImageIfReady() {
        guard downloadedPreviewImage != nil else {
            return
        }
        
        spinner.stopAnimating()
        previewImageView.image = downloadedPreviewImage
        downloadedPreviewImage = nil
        showContent(animated: true) { [weak self] _ in
            self?.playVideo()
        }
        
        let minWidth = UIScreen.mainScreen().bounds.size.width
        if let imageAsset = content.previewImage(ofMinimumWidth: minWidth) where configuration.showsBlurredBackground {
            setBackgroundBlur(withImageAsset: imageAsset, forContent: content)
        }
        else {
            backgroundView?.image = nil
        }
    }
    
    // Hack that ensure that the background extends a little beyond the frame bounds,
    // so that the guassian blur doesn't introduce shadow at the edges
    private func computeBackgroundBounds() -> CGRect {
        var backgroundBounds = bounds
        backgroundBounds.origin.x -= 10
        backgroundBounds.origin.y -= 10
        backgroundBounds.size.height += 20
        backgroundBounds.size.width += 20
        return backgroundBounds
    }
    
    private func setBackgroundBlur(withImageAsset imageAsset: ImageAssetModel, forContent content: ContentModel, completion: (()->())? = nil) {
        backgroundView?.applyBlurToImageURL(imageAsset.url, withRadius: Constants.blurRadius) { [weak self] in
            guard let currentContentID = content.id where currentContentID == self?.content.id else {
                return
            }
            self?.backgroundView?.alpha = 1
            completion?()
        }
    }

    // MARK: - Actions

    func onContentTap() {
        if configuration.allowsVideoControls && content.type == .video {
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
        return fontForKey("font.textpost")
    }
    
    var textPostColor: UIColor? {
        return colorForKey("color.textpost")
    }
    
    var textPostBackgroundImageURL: NSURL? {
        guard let urlString = stringForKey("backgroundImage.textpost") else {
            return nil
        }
        
        return NSURL(string: urlString)
    }
}
