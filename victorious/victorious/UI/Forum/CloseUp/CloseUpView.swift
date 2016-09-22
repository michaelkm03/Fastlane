//
//  CloseUpView.swift
//  victorious
//
//  Created by Vincent Ho on 4/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

protocol CloseUpViewDelegate: class {
    func closeUpView(closeUpView: CloseUpView, didSelectProfileForUserID userID: User.ID)
    func closeUpViewGridStreamDidUpdate(closeUpView: CloseUpView)
    func closeUpView(closeUpView: CloseUpView, didSelectLinkURL url: NSURL)
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
    private var maxContentHeight: CGFloat = CGFloat.max
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var headerSection: UIView!
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var userNameButton: UIButton!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var captionLabel: LinkLabel!
    @IBOutlet weak var relatedLabel: UILabel!
    @IBOutlet weak var closeUpContentContainerView: UIView!
    @IBOutlet weak var separatorBar: UIImageView!
    
    private(set) var mediaContentHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Variables
    
     weak var delegate: CloseUpViewDelegate?
    
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    private lazy var errorView: ErrorStateView = {
        return ErrorStateView.v_fromNib()
    }()

    private(set) var mediaContentView: MediaContentView?
    
    private var videoPlayer: VVideoPlayer?

    private var dependencyManager: VDependencyManager! {
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

    private func setupMediaContentView(for content: Content) -> MediaContentView {
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
    
    private var content: Content? {
        didSet {
            if oldValue?.id == content?.id {
                return
            }
            guard let content = content, let author = content.author else {
                return
            }
            
            removeMediaContentView()
            
            // Header
            userNameButton.setTitle(author.displayName, forState: .Normal)
            avatarView.user = author
            
            createdAtLabel.text = NSDate(timestamp: content.createdAt).stringDescribingTimeIntervalSinceNow(format: .concise, precision: .seconds) ?? ""
            
            captionLabel.detectUserTags(for: content) { [weak self] url in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.delegate?.closeUpView(strongSelf, didSelectLinkURL: url)
            }
            
            captionLabel.text = content.text
            
            let mediaContentView = setupMediaContentView(for: content)
            addMediaContentView(mediaContentView)
            mediaContentView.loadContent()
            
            // Update size
            self.frame.size = sizeForContent(content, withWidth: self.bounds.size.width)
        }
    }
    
    override func updateConstraints() {
        mediaContentView?.topAnchor.constraintEqualToAnchor(headerSection.bottomAnchor).active = true
        mediaContentView?.widthAnchor.constraintEqualToAnchor(headerSection.widthAnchor).active = true
        
        // The height of mediaContentView is being constraint to a constant since it's dynamic to the content.
        // In order to remove this constraint when we transition into a lightbox, we need to save this height constraint as a property.
        mediaContentHeightConstraint = mediaContentView?.heightAnchor.constraintEqualToConstant(height(for: content))
        mediaContentHeightConstraint?.active = true
        
        super.updateConstraints()
    }
    
    // MARK: - Frame/Size Calculations
    
    private func height(for content: Content?) -> CGFloat {
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
            
            removeMediaContentView()
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
    
    private func sizeForContent(content: Content?, withWidth width: CGFloat) -> CGSize {
        guard let content = content else {
            let aspectRatio = Constants.defaultAspectRatio
            return CGSize(
                width: width,
                height: width / aspectRatio
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
        guard let userID = content?.author?.id else {
            return
        }
        
        delegate?.closeUpView(self, didSelectProfileForUserID: userID)
    }
    
    // MARK: - Helpers
    
    private func contentHasText(content: Content) -> Bool {
        return content.text?.stringByTrimmingCharactersInSet(.whitespaceCharacterSet()).characters.count > 0
    }
    
    @objc private func closeUpDismissed() {
        dispatch_async(dispatch_get_main_queue()) {
            self.videoPlayer?.pause()
        }
    }
    
    private func configureFontsAndColors() {
        userNameButton.setTitleColor(dependencyManager.usernameColor, forState: .Normal)
        createdAtLabel.textColor = dependencyManager.timestampColor
        captionLabel.textColor = dependencyManager.captionColor
        captionLabel.tintColor = dependencyManager.linkColor
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
    
    
    private func addMediaContentView(mediaContentView: MediaContentView) {
        closeUpContentContainerView.addSubview(mediaContentView)
        self.mediaContentView = mediaContentView
        setNeedsUpdateConstraints()
    }
    
    private func removeMediaContentView() {
        mediaContentView?.removeFromSuperview()
        mediaContentView = nil
    }
    
    // MARK: - ConfigurableGridStreamHeader
    
    func decorateHeader(dependencyManager: VDependencyManager, withWidth width: CGFloat, maxHeight: CGFloat, content: Content?, hasError: Bool) {
        self.content = content
        errorView.hidden = !hasError
        closeUpContentContainerView.hidden = hasError
    }
    
    func sizeForHeader(dependencyManager: VDependencyManager, withWidth width: CGFloat, maxHeight: CGFloat, content: Content?, hasError: Bool) -> CGSize {
        if hasError {
            let aspectRatio = Constants.defaultAspectRatio
            return CGSize(
                width: width,
                height: width / aspectRatio
            )
        }
        else {
            return sizeForContent(content, withWidth: width)
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
            UIView.animateWithDuration(Constants.relatedAnimationDuration) {
                self.relatedLabel.alpha = items.count == 0 ? 0 : 1
            }
            self.delegate?.closeUpViewGridStreamDidUpdate(self)
        })
    }

    // MARK: - MediaContentViewDelegate

    func mediaContentView(mediaContentView: MediaContentView, didFinishLoadingContent content: Content) {
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

    func mediaContentView(mediaContentView: MediaContentView, didFinishPlaybackOfContent content: Content) {
        // No behavior yet
    }
    
    func mediaContentView(mediaContentView: MediaContentView, didSelectLinkURL url: NSURL) {
        delegate?.closeUpView(self, didSelectLinkURL: url)
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
    
    var linkColor: UIColor? {
        return colorForKey("color.text.link")
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
