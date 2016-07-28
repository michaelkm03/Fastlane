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
    /// Determines whether we want video control for video content. E.g.: Stage disables video control for video content
    let allowsVideoControls: Bool
    
    let fillMode: FillMode
}

/// Displays an image/video/GIF/Youtube video/text post upon setting the content property.
class MediaContentView: UIView, ContentVideoPlayerCoordinatorDelegate, UIGestureRecognizerDelegate, Presentable {

    let dependencyManager: VDependencyManager
    let content: ContentModel

    private weak var delegate: MediaContentViewDelegate?

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

    private var videoCoordinator: VContentVideoPlayerCoordinator?
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
    
    // MARK: - Life Cycle

    /// Sets up the content view with a zero frame. Use this initializer if created from code.
    init(
        content: ContentModel,
        dependencyManager: VDependencyManager,
        configuration: MediaContentViewConfiguration,
        delegate: MediaContentViewDelegate? = nil
    ) {
        self.content = content
        self.dependencyManager = dependencyManager
        self.configuration = configuration
        self.delegate = delegate
        
        super.init(frame: CGRect.zero)
        
        setup()
        configureBackground()
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
        
        addGestureRecognizer(singleTapRecognizer)
    }
    
    deinit {
        delegate = nil
        videoCoordinator?.delegate = nil
    }
    
    // MARK: - Configuration
    
    private var configuration: MediaContentViewConfiguration
    
    private func configureBackground() {
        previewImageView.contentMode = (configuration.fillMode == .fit) ? .ScaleAspectFit : .ScaleAspectFill
        
        let backgroundView = UIImageView()
        self.backgroundView = backgroundView
        backgroundView.contentMode = .ScaleAspectFill
        insertSubview(backgroundView, atIndex: 0)
    }

    // MARK: - Presentable

    func willBePresented() {
        videoCoordinator?.playVideo()
    }

    func willBeDismissed() {
        videoCoordinator?.pauseVideo()
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

    func loadContent() {
        spinner.startAnimating()
        
        // Set up image view if content is image
        let minWidth = frame.size.width
        
        if
            content.type.displaysAsImage,
            let imageAsset = content.previewImage(ofMinimumWidth: minWidth)
        {
            setUpPreviewImage(from: imageAsset)
        }
        else if content.type.displaysAsVideo {
            setUpVideoPlayer(for: content)
        }
        else if content.type == .text {
            setUpTextLabel()
        }
    }
    
    // MARK: - Managing preview image
    
    private func setUpPreviewImage(from imageAsset: ImageAssetModel? = nil) {
        tearDownVideoPlayer()
        
        previewImageView.hidden = false
        
        guard let imageSource = imageAsset?.imageSource else {
            return
        }
        
        switch imageSource {
            case .remote(let url):
                previewImageView.sd_setImageWithURL(
                    url,
                    placeholderImage: previewImageView.image, // Leave the image as is, since we want to wait until animation has finished before setting the image.
                    options: .AvoidAutoSetImage
                ) { [weak self] image, _, _, _ in
                    self?.previewImageView.image = image
                    self?.finishedLoadingContent()
                }
            case .local(let image):
                previewImageView.image = image
                finishedLoadingContent()
        }
    }
    
    private func finishedLoadingContent() {
        spinner.stopAnimating()
        delegate?.didFinishLoadingContent(content)
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
    
    // MARK: - Managing Text 
    
    private func setUpTextLabel() {
        setUpPreviewImage()
        
        let textPostDependency = self.dependencyManager.textPostDependency
        textPostLabel.font = textPostDependency?.textPostFont ?? Constants.defaultTextFont
        textPostLabel.textColor = textPostDependency?.textPostColor ?? Constants.defaultTextColor
        
        textPostLabel.hidden = true //Hide while we set up the view for the next post

        guard let url = textPostDependency?.textPostBackgroundImageURL else {
            return
        }

        previewImageView.sd_setImageWithURL(url) { [weak self] (_, _, _, _) in
            guard let text = self?.content.text else {
                return
            }
            self?.textPostLabel.text = text
            self?.textPostLabel.hidden = false
            
            self?.finishedLoadingContent()
        }
    }
    
    private func tearDownTextLabel() {
        textPostLabel.hidden = true
        textPostLabel.text = ""
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
        finishedLoadingContent()
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
