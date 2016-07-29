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
    func mediaContentView(mediaContentView: MediaContentView, didFinishLoadingContent content: ContentModel)

    /// A callback that tells the delegate that the piece of content has finished playing.
    func mediaContentView(mediaContentView: MediaContentView, didFinishPlaybackOfContent content: ContentModel)
}

enum FillMode {
    case fill
    case fit
}

/// Displays an image/video/GIF/Youtube video/text post upon setting the content property.
class MediaContentView: UIView, ContentVideoPlayerCoordinatorDelegate, UIGestureRecognizerDelegate, Presentable {
    struct AnimationConstants {
        static let mediaContentViewAnimationDuration = NSTimeInterval(0.75)
    }

    // MARK: - Public

    let content: ContentModel

    weak var delegate: MediaContentViewDelegate?

    // MARK: - Private

    private struct Constants {
        static let textPostLineSpacing: CGFloat = 2.0
        static let maxLineCount = 4
        static let textAlignment = NSTextAlignment.Center
        static let minimumScaleFactor: CGFloat = 0.8
        static let textPostPadding = 25
        static let defaultTextColor = UIColor.whiteColor()
        static let defaultTextFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    }

    private let dependencyManager: VDependencyManager

    private var videoCoordinator: VContentVideoPlayerCoordinator?

    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)

    private lazy var imageView = {
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

    private var allowsVideoControls: Bool

    private var fillMode: FillMode
    
    // MARK: - Life Cycle

    /// Sets up the content view with a zero frame. Use this initializer if created from code.
    init(
        content: ContentModel,
        dependencyManager: VDependencyManager,
        fillMode: FillMode,
        allowsVideoControls: Bool = false
    ) {
        self.content = content
        self.dependencyManager = dependencyManager
        self.fillMode = fillMode
        self.allowsVideoControls = allowsVideoControls

        super.init(frame: CGRect.zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Cannot create MCV from a Storyboard or NIB.")
    }
    
    private func setup() {
        clipsToBounds = true
        backgroundColor = .clearColor()
        imageView.contentMode = (fillMode == .fit) ? .ScaleAspectFit : .ScaleAspectFill
        
        addSubview(imageView)
        
        videoContainerView.backgroundColor = .clearColor()
        addSubview(videoContainerView)
        
        addSubview(textPostLabel)
  
        addSubview(spinner)
        sendSubviewToBack(spinner)
        
        addGestureRecognizer(singleTapRecognizer)
    }

    // MARK: - Presentable

    func willBePresented() {
        videoCoordinator?.playVideo(withSync: true)
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

        return videoCoordinator.duration >= content.seekAheadTime
    }

    func loadContent() {
        spinner.startAnimating()
        
        // Set up image view if content is image
        let minWidth = frame.size.width
        
        if content.type.displaysAsImage, let imageAsset = content.previewImage(ofMinimumWidth: minWidth) {
            setUpImageView(from: imageAsset)
        }
        else if content.type.displaysAsVideo {
            setUpVideoPlayer(for: content)
        }
        else if content.type == .text {
            setUpTextLabel()
        }
    }
    
    // MARK: - Managing preview image
    
    private func setUpImageView(from imageAsset: ImageAssetModel? = nil) {
        tearDownVideoPlayer()
        
        imageView.hidden = false
        
        guard let imageSource = imageAsset?.imageSource else {
            return
        }
        
        switch imageSource {
            case .remote(let url):
                imageView.sd_setImageWithURL(
                    url,
                    placeholderImage: imageView.image, // Leave the image as is, since we want to wait until animation has finished before setting the image.
                    options: .AvoidAutoSetImage
                ) { [weak self] image, _, _, _ in
                    self?.imageView.image = image
                    self?.finishedLoadingContent()
                }
            case .local(let image):
                imageView.image = image
                finishedLoadingContent()
        }
    }
    
    private func finishedLoadingContent() {
        spinner.stopAnimating()
        delegate?.mediaContentView(self, didFinishLoadingContent: content)
    }
    
    private func tearDownImageView() {
        imageView.hidden = true
    }
    
    // MARK: - Managing video
    
    private func setUpVideoPlayer(for content: ContentModel) {
        tearDownTextLabel()
        tearDownImageView()
        
        videoContainerView.hidden = false
        videoCoordinator?.tearDown()
        videoCoordinator = VContentVideoPlayerCoordinator(content: content)
        videoCoordinator?.setupVideoPlayer(in: videoContainerView)
        
        if allowsVideoControls {
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
        setUpImageView()
        
        let textPostDependency = self.dependencyManager.textPostDependency
        textPostLabel.font = textPostDependency?.textPostFont ?? Constants.defaultTextFont
        textPostLabel.textColor = textPostDependency?.textPostColor ?? Constants.defaultTextColor
        
        textPostLabel.hidden = true //Hide while we set up the view for the next post

        guard let url = textPostDependency?.textPostBackgroundImageURL else {
            return
        }

        imageView.sd_setImageWithURL(url) { [weak self] (_, _, _, _) in
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

        imageView.frame = bounds
        videoContainerView.frame = bounds
        textPostLabel.frame = CGRect(x: bounds.origin.x + CGFloat(Constants.textPostPadding), y: bounds.origin.y, width: bounds.width - CGFloat(2 * Constants.textPostPadding), height: bounds.height)
        spinner.center = CGPoint(x: bounds.midX, y: bounds.midY)
        videoCoordinator?.layout(in: videoContainerView.bounds, with: fillMode)

        if content.type == .image {
            loadContent()
        }
    }
    
    // MARK: - Actions

    func onContentTap() {
        if allowsVideoControls && content.type == .video {
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

    func coordinatorDidFinishPlaying() {
        delegate?.mediaContentView(self, didFinishPlaybackOfContent: content)
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
