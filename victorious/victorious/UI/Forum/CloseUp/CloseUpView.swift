//
//  CloseUpView.swift
//  victorious
//
//  Created by Vincent Ho on 4/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

protocol CloseUpViewDelegate {
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
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager,
                                        delegate: CloseUpViewDelegate? = nil) -> CloseUpView {
        guard let view = NSBundle.mainBundle().loadNibNamed("CloseUpView",
                                                            owner: self,
                                                            options: nil).first as? CloseUpView else {
                                                                fatalError("Could not load a close up view.")
        }
        view.dependencyManager = dependencyManager
        view.delegate = delegate
        return view
    }
    
    override func awakeFromNib() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2.0
        closeUpContentContainerView.layer.cornerRadius = 6.0
        clearContent()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(closeUpDismissed),
                                                         name: "closeUpDismissed",
                                                         object: nil)
        blurredImageView.alpha = blurredImageAlpha
    }
    
    @IBOutlet weak var lightOverlayView: UIView!
    @IBOutlet weak var blurredImageView: UIImageView!
    var dependencyManager: VDependencyManager! {
        didSet {
            configureFontsAndColors()
        }
    }
    var delegate: CloseUpViewDelegate?
    
    @IBAction func selectedProfile(sender: AnyObject) {
        delegate?.didSelectProfile()
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
        userNameButton.setTitle("", forState: UIControlState.Normal)
        createdAtLabel.text = ""
    }
    
    var maxHeight: CGFloat = CGFloat.max
    
    var viewedContent: VViewedContent? {
        didSet {
            guard let viewedContent = viewedContent,
                let author = viewedContent.author,
                let content = viewedContent.content else {
                return
            }
            
            
            // Header
            userNameButton.setTitle(author.name, forState: UIControlState.Normal)
            if let picturePath = author.pictureUrl, pictureURL = NSURL(string: picturePath) {
                profileImageView.sd_setImageWithURL(pictureURL,
                                                    placeholderImage: placeholderImage)
            }
            else {
                profileImageView.image = placeholderImage
            }
            let minWidth = CGRectGetWidth(UIScreen.mainScreen().bounds)

            if let preview = content.previewImageWithMinimumWidth(minWidth),
                let remoteSource = preview.imageURL,
                let remoteURL = NSURL(string: remoteSource) {
                blurredImageView.applyBlurToImageURL(remoteURL, withRadius: 12.0) { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.blurredImageView.alpha = blurredImageAlpha
                }
            }
            
            createdAtLabel.text = content.releasedAt?.stringDescribingTimeIntervalSinceNow(format: .concise, precision: .seconds) ?? ""
            captionLabel.text = content.title
            mediaContentView.content = content
            
            // Update size
            self.frame.size = sizeForContent(viewedContent)
        }
    }
    
    override func layoutSubviews() {
        guard let content = viewedContent?.content else {
            return
        }
        
        var totalHeight = CGRectGetHeight(headerSection.bounds) + headerSection.frame.origin.y
        
        let screenWidth = CGRectGetWidth(UIScreen.mainScreen().bounds)
        
        let contentAspectRatio = aspectRatio(for: content)
        let contentHeight: CGFloat = min(screenWidth / contentAspectRatio, maxHeight - CGRectGetHeight(headerSection.bounds))
        
        // Content
        var mediaContentViewFrame = mediaContentView.frame
        mediaContentViewFrame.origin.y = totalHeight
        mediaContentViewFrame.size.height = contentHeight
        mediaContentView.frame = mediaContentViewFrame
        
        totalHeight = totalHeight + CGRectGetHeight(mediaContentView.bounds)
        
        // Caption
        var frame = captionLabel.frame
        frame.origin.y = totalHeight + verticalMargins
        frame.size.width = screenWidth - 2 * horizontalMargins
        captionLabel.frame = frame
        captionLabel.sizeToFit()
        
    }
    
    func aspectRatio(for content: VContent) -> CGFloat {
        guard let preview = content.previewImages?.allObjects.first as? VContentPreview,
            let height = preview.height?.integerValue,
            let width = preview.width?.integerValue
            where height > 0 && width > 0 else {
            return 1.0
        }
        return CGFloat(width) / CGFloat(height)
    }
    
    func sizeForContent(viewedContent: VViewedContent) -> CGSize {
        guard let content = viewedContent.content else {
                return CGSizeZero
        }
        let screenWidth = CGRectGetWidth(UIScreen.mainScreen().bounds)
        
        let contentAspectRatio = aspectRatio(for: content)
        let contentHeight: CGFloat = min(screenWidth / contentAspectRatio, maxHeight - CGRectGetHeight(headerSection.bounds))
        
        if !contentHasTitle(content) {
            return CGSizeMake(screenWidth, CGRectGetHeight(headerSection.bounds) + contentHeight + CGRectGetHeight(relatedLabel.bounds))
        }
        
        var frame = captionLabel.frame
        frame.size.width = screenWidth - 2 * horizontalMargins
        captionLabel.frame = frame
        captionLabel.text = content.title
        captionLabel.sizeToFit()
        
        let height = CGRectGetHeight(headerSection.bounds) + contentHeight + CGRectGetHeight(captionLabel.bounds) + 2*verticalMargins + CGRectGetHeight(relatedLabel.bounds)
        return CGSizeMake(screenWidth, height)
    }
    
    private func contentHasTitle(content: VContent) -> Bool {
        guard let title = content.title else {
            return false
        }
        return title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).characters.count > 0
    }
    
    @objc private func closeUpDismissed() {
        if let videoPlayer = videoPlayer {
            print(videoPlayer)
            dispatch_async(dispatch_get_main_queue(), {
                videoPlayer.pause()
            })
        }
    }
    
    // MARK: - ConfigurableHeader
    
    func decorateHeader(dependencyManager: VDependencyManager,
                        maxHeight: CGFloat,
                        content: VViewedContent?) {
        self.viewedContent = content
    }
    
    func sizeForHeader(dependencyManager: VDependencyManager,
                       maxHeight: CGFloat,
                       content: VViewedContent?) -> CGSize {
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
