//
//  CloseUpView.swift
//  victorious
//
//  Created by Vincent Ho on 4/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

protocol CloseUpViewDelegate: class {
    func closeUpView(_ closeUpView: CloseUpView, didSelectProfileForUserID userID: User.ID)
    func closeUpViewGridStreamDidUpdate(_ closeUpView: CloseUpView)
    func closeUpView(_ closeUpView: CloseUpView, didSelectLinkURL url: URL)
}

class CloseUpView: UIView, ConfigurableGridStreamHeader, MediaContentViewDelegate {
    
    // MARK: - Configuration
    
    fileprivate struct Constants {
        static let relatedAnimationDuration = Double(1)
        static let horizontalMargins = CGFloat(16)
        static let verticalMargins = CGFloat(18)
        static let cornerRadius = CGFloat(6)
        static let topOffset = CGFloat(-20)
        static let defaultAspectRatio = CGFloat(1)
    }
    
    /// Maximum height of the close up view (set from the outside). Defaults to CGFloat.max
    fileprivate var maxContentHeight: CGFloat = CGFloat.greatestFiniteMagnitude
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var headerSection: UIView!
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var userNameButton: UIButton!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var captionLabel: LinkLabel!
    @IBOutlet weak var relatedLabel: UILabel!
    @IBOutlet weak var closeUpContentContainerView: UIView!
    @IBOutlet weak var separatorBar: UIImageView!
    
    fileprivate(set) var mediaContentHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Variables
    
    weak var delegate: CloseUpViewDelegate?
    
    fileprivate let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    fileprivate lazy var errorView: ErrorStateView = {
        return ErrorStateView.v_fromNib()
    }()

    fileprivate(set) var mediaContentView: MediaContentView?
    
    fileprivate var videoPlayer: VVideoPlayer?

    fileprivate var dependencyManager: VDependencyManager! {
        didSet {
            errorView.dependencyManager = dependencyManager.errorStateDependency
            configureFontsAndColors()
        }
    }
    
    // MARK: - Initialization
    
    class func new(withDependencyManager dependencyManager: VDependencyManager, delegate: CloseUpViewDelegate? = nil) -> CloseUpView {
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(closeUpDismissed),
            name: NSNotification.Name(rawValue: "closeUpDismissed"),
            object: nil
        )
        insertSubview(spinner, at: 0)
        spinner.startAnimating()
        
        separatorBar.image = UIImage.v_singlePixelImage(with: .white)
    }

    fileprivate func setupMediaContentView(for content: Content) -> MediaContentView {
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
    
    fileprivate var content: Content? {
        didSet {
            if oldValue?.id == content?.id {
                return
            }
            guard let content = content, let author = content.author else {
                return
            }
            
            removeMediaContentView()
            
            // Header
            userNameButton.setTitle(author.username, for: .normal)
            avatarView.user = author
            
            createdAtLabel.text = Date(timestamp: content.createdAt).stringDescribingTimeIntervalSinceNow(format: .concise, precision: .seconds)
            
            captionLabel.detectUserTags(for: content) { [weak self] url in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.delegate?.closeUpView(strongSelf, didSelectLinkURL: url as URL)
            }
            
            captionLabel.text = content.text
            
            let mediaContentView = setupMediaContentView(for: content)
            addMediaContentView(mediaContentView)
            mediaContentView.loadContent()
            
            // Update size
            self.frame.size = sizeForContent(content, withWidth: self.bounds.width)
        }
    }
    
    override func updateConstraints() {
        mediaContentView?.topAnchor.constraint(equalTo: headerSection.bottomAnchor).isActive = true
        mediaContentView?.widthAnchor.constraint(equalTo: headerSection.widthAnchor).isActive = true
        
        // The height of mediaContentView is being constraint to a constant since it's dynamic to the content.
        // In order to remove this constraint when we transition into a lightbox, we need to save this height constraint as a property.
        mediaContentHeightConstraint = mediaContentView?.heightAnchor.constraint(equalToConstant: height(for: content))
        mediaContentHeightConstraint?.isActive = true
        
        super.updateConstraints()
    }
    
    // MARK: - Frame/Size Calculations
    
    fileprivate func height(for content: Content?) -> CGFloat {
        guard let aspectRatio = content?.naturalMediaAspectRatio else {
            return 0
        }
        
        // Hack since CUV should always be full screen width anyway, and the parent containers use autolayout.
        return min(UIScreen.main.bounds.width / aspectRatio, maxContentHeight - headerSection.bounds.height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var totalHeight = headerSection.frame.maxY
        
        if content == nil {
            var bounds = self.bounds
            bounds.size.height = bounds.height - relatedLabel.frame.height
            errorView.frame = bounds
            
            removeMediaContentView()
        }
        else {
            totalHeight += height(for: content)
            
            // Caption
            var frame = captionLabel.frame
            frame.origin.y = totalHeight + Constants.verticalMargins
            frame.size.width = bounds.width - 2 * Constants.horizontalMargins
            captionLabel.frame = frame
            captionLabel.sizeToFit()
        }
        spinner.center = center
    }
    
    fileprivate func sizeForContent(_ content: Content?, withWidth width: CGFloat) -> CGSize {
        guard let content = content else {
            let aspectRatio = Constants.defaultAspectRatio
            return CGSize(
                width: width,
                height: width / aspectRatio
            )
        }
        
        let contentHeight = height(for: content)
        let width = bounds.width
        
        if !contentHasText(content) {
            return CGSize(
                width: width,
                height: headerSection.bounds.height + contentHeight + relatedLabel.bounds.height
            )
        }
        
        var frame = captionLabel.frame
        frame.size.width = width - 2 * Constants.horizontalMargins
        captionLabel.frame = frame
        captionLabel.text = content.text
        captionLabel.sizeToFit()
        
        let totalHeight = headerSection.bounds.height +
            contentHeight +
            captionLabel.bounds.height +
            2 * Constants.verticalMargins +
            relatedLabel.bounds.height
        
        return CGSize(
            width: width,
            height: totalHeight
        )
    }
    
    @IBAction func selectedProfile(_ sender: AnyObject) {
        showProfile()
    }
    
    fileprivate dynamic func showProfile() {
        guard let userID = content?.author?.id else {
            return
        }
        
        delegate?.closeUpView(self, didSelectProfileForUserID: userID)
    }
    
    // MARK: - Helpers
    
    fileprivate func contentHasText(_ content: Content) -> Bool {
        return content.text?.trimmingCharacters(in: CharacterSet.whitespaces).characters.count ?? 0 > 0
    }
    
    @objc fileprivate func closeUpDismissed() {
        DispatchQueue.main.async {
            self.videoPlayer?.pause()
        }
    }
    
    fileprivate func configureFontsAndColors() {
        userNameButton.setTitleColor(dependencyManager.usernameColor, for: .normal)
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
            separatorBar.image = UIImage.v_singlePixelImage(with: relatedColor)
        }
    }
    
    fileprivate func clearContent() {
        captionLabel.text = ""
        avatarView.user = nil
        userNameButton.setTitle("", for: UIControlState())
        createdAtLabel.text = ""
        relatedLabel.alpha = 0
    }
    
    
    fileprivate func addMediaContentView(_ mediaContentView: MediaContentView) {
        closeUpContentContainerView.addSubview(mediaContentView)
        self.mediaContentView = mediaContentView
        setNeedsUpdateConstraints()
    }
    
    fileprivate func removeMediaContentView() {
        mediaContentView?.removeFromSuperview()
        mediaContentView = nil
    }
    
    // MARK: - ConfigurableGridStreamHeader
    
    func decorateHeader(_ dependencyManager: VDependencyManager, withWidth width: CGFloat, maxHeight: CGFloat, content: Content?, hasError: Bool) {
        self.content = content
        errorView.isHidden = !hasError
        closeUpContentContainerView.isHidden = hasError
    }
    
    func sizeForHeader(_ dependencyManager: VDependencyManager, withWidth width: CGFloat, maxHeight: CGFloat, content: Content?, hasError: Bool) -> CGSize {
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
        DispatchQueue.main.async(execute: {
            UIView.animate(withDuration: Constants.relatedAnimationDuration) {
                self.relatedLabel.alpha = items.count == 0 ? 0 : 1
            }
            self.delegate?.closeUpViewGridStreamDidUpdate(self)
        })
    }

    // MARK: - MediaContentViewDelegate

    func mediaContentView(_ mediaContentView: MediaContentView, didFinishLoadingContent content: Content) {
        UIView.animate(
            withDuration: MediaContentView.AnimationConstants.mediaContentViewAnimationDuration,
            animations: {
                mediaContentView.alpha = 1.0
            },
            completion: { [weak self]  _ in
                self?.spinner.stopAnimating()
            }
        )
    }

    func mediaContentView(_ mediaContentView: MediaContentView, didFinishPlaybackOfContent content: Content) {
        // No behavior yet
    }
    
    func mediaContentView(_ mediaContentView: MediaContentView, didSelectLinkURL url: URL) {
        delegate?.closeUpView(self, didSelectLinkURL: url)
    }
}

// MARK: - Dependencies

private extension VDependencyManager {
    var usernameColor: UIColor? {
        return color(forKey: "color.text.header")
    }
    
    var timestampColor: UIColor? {
        return color(forKey: "color.text.secondary")
    }
    
    var captionColor: UIColor? {
        return color(forKey: "color.text.content")
    }
    
    var linkColor: UIColor? {
        return color(forKey: "color.text.link")
    }
    
    var relatedColor: UIColor? {
        return color(forKey: "color.text.subcontent")
    }
    
    var usernameFont: UIFont? {
        return font(forKey: "font.header")
    }
    
    var timestampFont: UIFont? {
        return font(forKey: "font.secondary")
    }
    
    var captionFont: UIFont? {
        return font(forKey: "font.content")
    }
    
    var relatedFont: UIFont? {
        return font(forKey: "font.subcontent")
    }
    
    var relatedText: String? {
        return string(forKey: "related_text")
    }
    
    var errorStateDependency: VDependencyManager? {
        return childDependency(forKey: "error.state")
    }
}
