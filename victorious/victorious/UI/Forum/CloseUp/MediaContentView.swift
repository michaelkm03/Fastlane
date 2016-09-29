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
    func mediaContentView(_ mediaContentView: MediaContentView, didFinishLoadingContent content: Content)

    /// A callback that tells the delegate that the piece of content has finished playing.
    func mediaContentView(_ mediaContentView: MediaContentView, didFinishPlaybackOfContent content: Content)
    
    /// A callback that tells the delegate that a URL has been selected from a link in the content's text.
    func mediaContentView(_ mediaContentView: MediaContentView, didSelectLinkURL url: URL)
}

enum FillMode {
    case fill
    case fit
}

/// Displays an image/video/GIF/Youtube video/text post upon setting the content property.
class MediaContentView: UIView, ContentVideoPlayerCoordinatorDelegate, UIGestureRecognizerDelegate, Presentable {
    struct AnimationConstants {
        static let mediaContentViewAnimationDuration = TimeInterval(0.75)
    }

    // MARK: - Public

    let content: Content

    weak var delegate: MediaContentViewDelegate?

    // MARK: - Private

    fileprivate struct Constants {
        static let textPostLineSpacing: CGFloat = 2.0
        static let maxLineCount = 4
        static let textAlignment = NSTextAlignment.center
        static let minimumScaleFactor: CGFloat = 0.8
        static let textPostPadding = 25
        static let defaultTextColor = UIColor.white
        static let defaultTextFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        static let imageReloadThreshold = CGFloat(0.75)
    }

    fileprivate let dependencyManager: VDependencyManager

    fileprivate var videoCoordinator: VContentVideoPlayerCoordinator?

    fileprivate let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    fileprivate let shouldSyncOnReappearance: Bool

    fileprivate lazy var imageView = {
        return UIImageView()
    }()

    fileprivate lazy var textPostLabel: LinkLabel = {
        let label = LinkLabel()
        label.textAlignment = Constants.textAlignment
        label.numberOfLines = Constants.maxLineCount
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = Constants.minimumScaleFactor
        return label
    }()

    fileprivate lazy var videoContainerView = {
        return VPassthroughContainerView()
    }()
    
    fileprivate lazy var singleTapRecognizer: UITapGestureRecognizer = {
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onContentTap))
        singleTapRecognizer.numberOfTapsRequired = 1
        singleTapRecognizer.delegate = self
        singleTapRecognizer.cancelsTouchesInView = false
        return singleTapRecognizer
    }()

    fileprivate var allowsVideoControls: Bool

    fileprivate var fillMode: FillMode

    fileprivate var lastFrameSize = CGSize.zero
    
    // MARK: - Life Cycle

    /// Sets up the content view with a zero frame. Use this initializer if created from code.
    init(
        content: Content,
        dependencyManager: VDependencyManager,
        fillMode: FillMode,
        allowsVideoControls: Bool = false,
        shouldSyncOnReappearance: Bool = false
    ) {
        self.content = content
        self.dependencyManager = dependencyManager
        self.fillMode = fillMode
        self.allowsVideoControls = allowsVideoControls
        self.shouldSyncOnReappearance = shouldSyncOnReappearance

        super.init(frame: CGRect.zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Cannot create MCV from a Storyboard or NIB.")
    }
    
    fileprivate func setup() {
        clipsToBounds = true
        backgroundColor = .clear
        imageView.contentMode = (fillMode == .fit) ? .scaleAspectFit : .scaleAspectFill
        
        addSubview(imageView)
        
        videoContainerView.backgroundColor = .clear
        addSubview(videoContainerView)
        
        addSubview(textPostLabel)
  
        addSubview(spinner)
        sendSubview(toBack: spinner)
        
        addGestureRecognizer(singleTapRecognizer)
    }

    // MARK: - Presentable

    func didPresent() {
        videoCoordinator?.playVideo(withSync: shouldSyncOnReappearance)
    }

    func willBeDismissed() {
        videoCoordinator?.pauseVideo()
    }

    // MARK: - Managing content
    
    var hasValidMedia: Bool {
        switch content.type {
            case .gif, .image, .link, .text:
                return true
            case .video:
                return seekableWithinBounds
        }
    }

    /// Can we seek ahead into the item with the current seekAheadTime stored in the content.
    fileprivate var seekableWithinBounds: Bool {
        // Since the youtube player will return duration = 0 for live streams, we check if the 
        // duration is 0. If that is the case, we return true for seekable.
        if content.assets.first?.videoSource == .youtube && videoCoordinator?.duration == 0 {
            return true
        }

        // Duration will be NaN if the item hasn't loaded yet.
        guard let videoCoordinator = videoCoordinator , !videoCoordinator.duration.isNaN else {
            return false
        }

        return videoCoordinator.duration >= content.seekAheadTime ?? 0
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
    
    fileprivate func setUpImageView(from imageAsset: ImageAssetModel) {
        tearDownVideoPlayer()
        tearDownTextLabel()
        
        imageView.isHidden = false
        
        imageView.getImageAsset(imageAsset) { [weak self] result in
            switch result {
                case .success(let image):
                    self?.imageView.image = image
                    self?.finishedLoadingContent()
                case .failure(_):
                    break
            }
        }
    }
    
    fileprivate func finishedLoadingContent() {
        spinner.stopAnimating()
        delegate?.mediaContentView(self, didFinishLoadingContent: content)
    }
    
    fileprivate func tearDownImageView() {
        imageView.isHidden = true
        imageView.image = nil
    }
    
    // MARK: - Managing video
    
    fileprivate func setUpVideoPlayer(for content: Content) {
        tearDownTextLabel()
        tearDownImageView()
        
        videoContainerView.isHidden = false
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
    
    fileprivate func tearDownVideoPlayer() {
        videoContainerView.isHidden = true
        videoCoordinator?.tearDown()
        videoCoordinator = nil
    }
    
    // MARK: - Managing Text 
    
    fileprivate func setUpTextLabel() {
        tearDownVideoPlayer()
        tearDownImageView()
        
        let textPostDependency = self.dependencyManager.textPostDependency
        textPostLabel.font = textPostDependency?.textPostFont ?? Constants.defaultTextFont
        textPostLabel.textColor = textPostDependency?.textPostColor ?? Constants.defaultTextColor
        textPostLabel.tintColor = textPostDependency?.linkColor
        
        textPostLabel.isHidden = true //Hide while we set up the view for the next post

        guard let url = textPostDependency?.textPostBackgroundImageURL else {
            return
        }

        imageView.sd_setImage(with: url as URL) { [weak self] _ in
            self?.textPostLabel.detectUserTags(for: self?.content) { [weak self] url in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.delegate?.mediaContentView(strongSelf, didSelectLinkURL: url as URL)
            }
            
            guard let text = self?.content.text else {
                return
            }
            
            self?.textPostLabel.text = text
            self?.textPostLabel.isHidden = false
            self?.imageView.isHidden = false
            self?.finishedLoadingContent()
        }
    }
    
    fileprivate func tearDownTextLabel() {
        textPostLabel.isHidden = true
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

        // We need to reload the image content if the size has changed above the threshold since MCV is initialized with a 0 size.
        if content.type.displaysAsImage && (lastFrameSize.area / bounds.size.area) < Constants.imageReloadThreshold {
            lastFrameSize = bounds.size
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
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
        return font(forKey: "font.textpost")
    }
    
    var textPostColor: UIColor? {
        return color(forKey: "color.textpost")
    }
    
    var linkColor: UIColor? {
        return color(forKey: "color.link")
    }
    
    var textPostBackgroundImageURL: NSURL? {
        guard let urlString = string(forKey: "backgroundImage.textpost") else {
            return nil
        }
        
        return NSURL(string: urlString)
    }
}
