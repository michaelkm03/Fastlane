//
//  CloseUpView.swift
//  victorious
//
//  Created by Vincent Ho on 4/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

protocol CloseUpViewDelegate: class {
    func didSelectProfileForUserID(userID: Int)
    func gridStreamDidUpdate()
}

class CloseUpView: UIView, ConfigurableGridStreamHeader, MediaContentViewDelegate {
    
    // MARK: - Configuration
    
    private struct Constants {
        static let relatedAnimationDuration = Double(1)
        static let horizontalMargins = CGFloat(16)
        static let verticalMargins = CGFloat(18)
        static let cornerRadius = CGFloat(6)
        static let topOffset = CGFloat(-20)
        static let defaultAspectRatio = CGFloat(1)
    }
    
    /// Maximum height of the close up view (set from the outside). Defaults to CGFloat.max
    var maxContentHeight: CGFloat = CGFloat.max
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var headerSection: UIView!
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var userNameButton: UIButton!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var relatedLabel: UILabel!
    @IBOutlet weak var closeUpContentContainerView: UIView!
    @IBOutlet weak var separatorBar: UIImageView!
    
    // MARK: - Variables
    
    weak var delegate: CloseUpViewDelegate?
    
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    private lazy var errorView: ErrorStateView = {
        return ErrorStateView.v_fromNib()
    }()

    private(set) var mediaContentView: MediaContentView?
    
    private var videoPlayer: VVideoPlayer?

    var dependencyManager: VDependencyManager! {
        didSet {
            errorView.dependencyManager = dependencyManager.errorStateDependency
            configureFontsAndColors()
        }
    }
    
    // MARK: - Initialization
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager, delegate: CloseUpViewDelegate? = nil) -> CloseUpView {
        let view : CloseUpView = CloseUpView.v_fromNib()
        view.dependencyManager = dependencyManager
        view.delegate = delegate
        return view
    }
    
    override func awakeFromNib() {
        addSubview(errorView)
        
        avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showProfile)))
        
        closeUpContentContainerView.layer.cornerRadius = Constants.cornerRadius
        clearContent()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(closeUpDismissed),
            name: "closeUpDismissed",
            object: nil
        )
        insertSubview(spinner, atIndex: 0)
        spinner.startAnimating()
        
        separatorBar.image = UIImage.v_singlePixelImageWithColor(.whiteColor())
    }

    private func setupMediaContentView(for content: ContentModel) -> MediaContentView {
        let mediaContentView = MediaContentView(
            content: content,
            dependencyManager: dependencyManager,
            fillMode: .fit,
            allowsVideoControls: true,
            shouldSyncOnReappearance: true
        )
        mediaContentView.delegate = self
        mediaContentView.alpha = 0
        mediaContentView.translatesAutoresizingMaskIntoConstraints = false
        
        return mediaContentView
    }
    
    // MARK: - Setting Content
    
    func setHeader(for content: ContentModel, author: UserModel ) {
        userNameButton.setTitle(author.displayName, forState: .Normal)
        
        avatarView.user = author
        createdAtLabel.text = NSDate(timestamp: content.createdAt).stringDescribingTimeIntervalSinceNow(format: .concise, precision: .seconds) ?? ""
        captionLabel.text = content.text
    }

    var content: ContentModel? {
        didSet {
            if oldValue?.id == content?.id {
                return
            }
            guard let content = content else {
                return
            }
            
            self.mediaContentView?.removeFromSuperview()
            
            let author = content.author
            
            setHeader(for: content, author: author)
            
            // Header
            userNameButton.setTitle(author.displayName, forState: .Normal)
            avatarView.user = author
            
            createdAtLabel.text = NSDate(timestamp: content.createdAt).stringDescribingTimeIntervalSinceNow(format: .concise, precision: .seconds) ?? ""
            captionLabel.text = content.text
            
            let mediaContentView = setupMediaContentView(for: content)
            closeUpContentContainerView.addSubview(mediaContentView)
            self.mediaContentView = mediaContentView
            mediaContentView.loadContent()
            
            // Update size
            self.frame.size = sizeForContent(content)
        }
    }
    
    override func updateConstraints() {
        mediaContentView?.topAnchor.constraintEqualToAnchor(headerSection.bottomAnchor).active = true
        mediaContentView?.widthAnchor.constraintEqualToConstant(UIScreen.mainScreen().bounds.width).active = true
        mediaContentView?.heightAnchor.constraintEqualToConstant(height(for: content)).active = true
        
        super.updateConstraints()
    }
    
    // MARK: - Frame/Size Calculations
    
    func height(for content: ContentModel?) -> CGFloat {
        guard let aspectRatio = content?.naturalMediaAspectRatio else {
            return 0
        }
        
        // Hack since CUV should always be full screen width anyway, and the parent containers use autolayout.
        return min(UIScreen.mainScreen().bounds.size.width / aspectRatio, maxContentHeight - headerSection.bounds.size.height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var totalHeight = headerSection.bounds.size.height + headerSection.frame.origin.y
        
        if content == nil {
            var bounds = self.bounds
            bounds.size.height = bounds.size.height - relatedLabel.frame.size.height
            errorView.frame = bounds
            
            mediaContentView?.removeFromSuperview()
            mediaContentView = nil
        }
        else {
            totalHeight += height(for: content)
            
            // Caption
            var frame = captionLabel.frame
            frame.origin.y = totalHeight + Constants.verticalMargins
            frame.size.width = bounds.size.width - 2 * Constants.horizontalMargins
            captionLabel.frame = frame
            captionLabel.sizeToFit()
        }
        spinner.center = center
    }
    
    func sizeForContent(content: ContentModel?) -> CGSize {
        guard let content = content else {
            let screenWidth = UIScreen.mainScreen().bounds.size.width
            let aspectRatio = Constants.defaultAspectRatio
            return CGSize(
                width: screenWidth,
                height: screenWidth / aspectRatio
            )
        }
        
        let contentHeight = height(for: content)
        let width = bounds.size.width
        
        if !contentHasText(content) {
            return CGSize(
                width: width,
                height: headerSection.bounds.size.height + contentHeight + relatedLabel.bounds.size.height
            )
        }
        
        var frame = captionLabel.frame
        frame.size.width = width - 2 * Constants.horizontalMargins
        captionLabel.frame = frame
        captionLabel.text = content.text
        captionLabel.sizeToFit()
        
        let totalHeight = headerSection.bounds.size.height +
            contentHeight +
            captionLabel.bounds.size.height +
            2 * Constants.verticalMargins +
            relatedLabel.bounds.size.height
        
        return CGSize(
            width: width,
            height: totalHeight
        )
    }
    
    @IBAction func selectedProfile(sender: AnyObject) {
        showProfile()
    }
    
    private dynamic func showProfile() {
        guard let userID = content?.author.id else {
            return
        }
        delegate?.didSelectProfileForUserID(userID)
    }
    
    // MARK: - Helpers
    
    private func contentHasText(content: ContentModel) -> Bool {
        return content.text?.stringByTrimmingCharactersInSet(.whitespaceCharacterSet()).characters.count > 0
    }
    
    @objc private func closeUpDismissed() {
        if let videoPlayer = videoPlayer {
            dispatch_async(dispatch_get_main_queue(), {
                videoPlayer.pause()
            })
        }
    }
    
    private func configureFontsAndColors() {
        userNameButton.setTitleColor(dependencyManager.usernameColor, forState: .Normal)
        createdAtLabel.textColor = dependencyManager.timestampColor
        captionLabel.textColor = dependencyManager.captionColor
        userNameButton.titleLabel!.font = dependencyManager.usernameFont
        createdAtLabel.font = dependencyManager.timestampFont
        captionLabel.font = dependencyManager.captionFont
        relatedLabel.textColor = dependencyManager.relatedColor
        relatedLabel.font = dependencyManager.relatedFont
        relatedLabel.text = dependencyManager.relatedText
        if let relatedColor = dependencyManager.relatedColor {
            separatorBar.image = UIImage.v_singlePixelImageWithColor(relatedColor)
        }
    }
    
    private func clearContent() {
        captionLabel.text = ""
        avatarView.user = nil
        userNameButton.setTitle("", forState: .Normal)
        createdAtLabel.text = ""
        relatedLabel.alpha = 0
    }
    
    // MARK: - ConfigurableGridStreamHeader
    
    func decorateHeader(dependencyManager: VDependencyManager, maxHeight: CGFloat, content: ContentModel?, hasError: Bool) {
        self.content = content
        errorView.hidden = !hasError
        closeUpContentContainerView.hidden = hasError
    }
    
    func sizeForHeader(dependencyManager: VDependencyManager, maxHeight: CGFloat, content: ContentModel?, hasError: Bool) -> CGSize {
        if hasError {
            let screenWidth = UIScreen.mainScreen().bounds.size.width
            let aspectRatio = Constants.defaultAspectRatio
            return CGSize(
                width: screenWidth,
                height: screenWidth / aspectRatio
            )
        }
        else {
            return sizeForContent(content)
        }
    }
    
    func headerDidAppear() {
        mediaContentView?.didPresent()
    }
    
    func headerWillDisappear() {
        mediaContentView?.willBeDismissed()
    }
    
    func gridStreamDidUpdateDataSource(with items: [Content]) {
        dispatch_async(dispatch_get_main_queue(), {
            UIView.animateWithDuration(Constants.relatedAnimationDuration, animations: {
                self.relatedLabel.alpha = items.count == 0 ? 0 : 1
            })
            self.delegate?.gridStreamDidUpdate()
        })
    }

    // MARK: - MediaContentViewDelegate

    func mediaContentView(mediaContentView: MediaContentView, didFinishLoadingContent content: ContentModel) {
        UIView.animateWithDuration(
            MediaContentView.AnimationConstants.mediaContentViewAnimationDuration,
            animations: {
                mediaContentView.alpha = 1.0
            },
            completion: { [weak self]  _ in
                self?.spinner.stopAnimating()
            }
        )
    }

    func mediaContentView(mediaContentView: MediaContentView, didFinishPlaybackOfContent content: ContentModel) {
        // No behavior yet
    }
}

// MARK: - Dependencies

private extension VDependencyManager {
    var usernameColor: UIColor? {
        return colorForKey("color.text.header")
    }
    
    var timestampColor: UIColor? {
        return colorForKey("color.text.secondary")
    }
    
    var captionColor: UIColor? {
        return colorForKey("color.text.content")
    }
    
    var relatedColor: UIColor? {
        return colorForKey("color.text.subcontent")
    }
    
    var usernameFont: UIFont? {
        return fontForKey("font.header")
    }
    
    var timestampFont: UIFont? {
        return fontForKey("font.secondary")
    }
    
    var captionFont: UIFont? {
        return fontForKey("font.content")
    }
    
    var relatedFont: UIFont? {
        return fontForKey("font.subcontent")
    }
    
    var relatedText: String? {
        return stringForKey("related_text")
    }
    
    var errorStateDependency: VDependencyManager? {
        return childDependencyForKey("error.state")
    }
}
