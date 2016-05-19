//
//  CloseUpView.swift
//  victorious
//
//  Created by Vincent Ho on 4/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

protocol CloseUpViewDelegate: class {
    func didSelectProfile()
}

private let blurredImageAlpha: CGFloat = 0.5

class CloseUpView: UIView, ConfigurableGridStreamHeader {
    @IBOutlet weak var headerSection: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameButton: UIButton!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var mediaContentView: MediaContentView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var relatedLabel: UILabel!
    @IBOutlet weak var closeUpContentContainerView: UIView!
    
    private var videoPlayer: VVideoPlayer?
    private let placeholderImage = UIImage(named: "profile_full")
    private let horizontalMargins: CGFloat = 16
    private let verticalMargins: CGFloat = 18
    private let screenWidth = UIScreen.mainScreen().bounds.size.width
    
    @IBOutlet weak var lightOverlayView: UIView!
    @IBOutlet weak var blurredImageView: UIImageView!
    
    weak var delegate: CloseUpViewDelegate?
    
    /// Maximum height of the close up view (set from the outside). Defaults to CGFloat.max
    var maxContentHeight: CGFloat = CGFloat.max
    
    var dependencyManager: VDependencyManager! {
        didSet {
            configureFontsAndColors()
        }
    }
    
    func height(for content: VContent?) -> CGFloat {
        guard let content = content else {
            return 0
        }
        let contentAspectRatio = content.aspectRatio
        return min(screenWidth / contentAspectRatio, maxContentHeight - headerSection.bounds.size.height)
    }

    var content: VContent? {
        didSet {
            guard let content = content,
                let author = content.author else {
                    return
            }
            
            setBackground(for: content)
            setHeader(for: content, author: author)
            
            // Header
            userNameButton.setTitle(author.name, forState: .Normal)
            if let pictureURL = author.pictureURL(ofMinimumSize: profileImageView.frame.size) {
                profileImageView.sd_setImageWithURL(pictureURL,
                                                    placeholderImage: placeholderImage)
            }
            else {
                profileImageView.image = placeholderImage
            }
            let minWidth = UIScreen.mainScreen().bounds.size.width
            
            if let preview = content.previewImageWithMinimumWidth(minWidth),
                let remoteSource = preview.imageURL,
                let remoteURL = NSURL(string: remoteSource) {
                blurredImageView.applyBlurToImageURL(remoteURL, withRadius: 12.0) { [weak self] in
                    self?.blurredImageView.alpha = blurredImageAlpha
                }
            }
            
            createdAtLabel.text = content.releasedAt?.stringDescribingTimeIntervalSinceNow(format: .concise, precision: .seconds) ?? ""
            captionLabel.text = content.title
            mediaContentView.updateContent(content)
            
            // Update size
            self.frame.size = sizeForContent(content)
        }
    }
    
    func setHeader(for content: VContent, author: VUser ) {
        userNameButton.setTitle(author.name, forState: .Normal)
        if let pictureURL = author.pictureURL(ofMinimumSize: profileImageView.frame.size) {
            profileImageView.sd_setImageWithURL(pictureURL,
                                                placeholderImage: placeholderImage)
        }
        else {
            profileImageView.image = placeholderImage
        }
        createdAtLabel.text = content.releasedAt?.stringDescribingTimeIntervalSinceNow(format: .concise, precision: .seconds) ?? ""
        captionLabel.text = content.title
    }
    
    func setBackground(for content: VContent) {
        let minWidth = UIScreen.mainScreen().bounds.size.width
        if let preview = content.previewImageWithMinimumWidth(minWidth),
            let remoteSource = preview.imageURL,
            let remoteURL = NSURL(string: remoteSource) {
            blurredImageView.applyBlurToImageURL(remoteURL, withRadius: 12.0) { [weak self] in
                self?.blurredImageView.alpha = blurredImageAlpha
            }
        }
    }
    
    @IBAction func selectedProfile(sender: AnyObject) {
        delegate?.didSelectProfile()
    }
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager,
                                        delegate: CloseUpViewDelegate? = nil) -> CloseUpView {
        let view : CloseUpView = CloseUpView.v_fromNib()
        view.dependencyManager = dependencyManager
        view.delegate = delegate
        return view
    }
    
    override func awakeFromNib() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.v_roundCornerRadius
        closeUpContentContainerView.layer.cornerRadius = 6.0
        clearContent()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(closeUpDismissed),
                                                         name: "closeUpDismissed",
                                                         object: nil)
        blurredImageView.alpha = blurredImageAlpha
    }
    
    func configureFontsAndColors() {
        userNameButton.setTitleColor(dependencyManager.usernameColor, forState: .Normal)
        createdAtLabel.textColor = dependencyManager.timestampColor
        captionLabel.textColor = dependencyManager.captionColor
        userNameButton.titleLabel!.font = dependencyManager.usernameFont
        createdAtLabel.font = dependencyManager.timestampFont
        captionLabel.font = dependencyManager.captionFont
        relatedLabel.textColor = dependencyManager.usernameColor
        relatedLabel.font = dependencyManager.relatedFont
        relatedLabel.text = dependencyManager.relatedText
    }
    
    func clearContent() {
        captionLabel.text = ""
        profileImageView.image = nil
        userNameButton.setTitle("", forState: .Normal)
        createdAtLabel.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if content == nil {
            return
        }
        
        var totalHeight = headerSection.bounds.size.height + headerSection.frame.origin.y
        
        // Content
        var mediaContentViewFrame = mediaContentView.frame
        mediaContentViewFrame.origin.y = totalHeight
        mediaContentViewFrame.size.height = height(for: content)
        mediaContentView.frame = mediaContentViewFrame
        
        totalHeight = totalHeight + mediaContentView.bounds.size.height
        
        // Caption
        var frame = captionLabel.frame
        frame.origin.y = totalHeight + verticalMargins
        frame.size.width = screenWidth - 2 * horizontalMargins
        captionLabel.frame = frame
        captionLabel.sizeToFit()
        
    }
    
    func sizeForContent(content: VContent) -> CGSize {
        let contentHeight = height(for: content)
        
        if !contentHasTitle(content) {
            return CGSize(
                width: screenWidth,
                height: headerSection.bounds.size.height + contentHeight + relatedLabel.bounds.size.height
            )
        }
        
        var frame = captionLabel.frame
        frame.size.width = screenWidth - 2 * horizontalMargins
        captionLabel.frame = frame
        captionLabel.text = content.title
        captionLabel.sizeToFit()
        
        let totalHeight = headerSection.bounds.size.height +
            contentHeight +
            captionLabel.bounds.size.height +
            2*verticalMargins +
            relatedLabel.bounds.size.height
        
        return CGSize(
            width: screenWidth,
            height: totalHeight
        )
    }
    
    private func contentHasTitle(content: VContent) -> Bool {
        guard let title = content.title else {
            return false
        }
        return title.stringByTrimmingCharactersInSet(.whitespaceCharacterSet()).characters.count > 0
    }
    
    @objc private func closeUpDismissed() {
        if let videoPlayer = videoPlayer {
            dispatch_async(dispatch_get_main_queue(), {
                videoPlayer.pause()
            })
        }
    }
    
    // MARK: - ConfigurableHeader
    
    func decorateHeader(dependencyManager: VDependencyManager,
                        maxHeight: CGFloat,
                        content: VContent?) {
        self.content = content
    }
    
    func sizeForHeader(dependencyManager: VDependencyManager,
                       maxHeight: CGFloat,
                       content: VContent?) -> CGSize {
        guard let content = content else {
            return CGSizeZero
        }
        return sizeForContent(content)
    }
}

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
}
