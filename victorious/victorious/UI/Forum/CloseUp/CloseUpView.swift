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
}

private let blurredImageAlpha: CGFloat = 0.5

class CloseUpView: UIView, ConfigurableGridStreamHeader {
    private static let relatedAnimationDuration: Double = 1
    
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
    
    func height(for content: ContentModel?) -> CGFloat {
        guard let aspectRatio = content?.naturalMediaAspectRatio else {
            return 0
        }
        return min(screenWidth / aspectRatio, maxContentHeight - headerSection.bounds.size.height)
    }

    var content: ContentModel? {
        didSet {
            if oldValue?.id == content?.id {
                return
            }
            guard let content = content else {
                return
            }
            
            let author = content.author
            
            setHeader(for: content, author: author)
            
            // Header
            userNameButton.setTitle(author.name, forState: .Normal)
            
            if let pictureURL = author.previewImageURL(ofMinimumSize: profileImageView.frame.size) {
                profileImageView.sd_setImageWithURL(pictureURL, placeholderImage: placeholderImage)
            } else {
                profileImageView.image = placeholderImage
            }
            
            let minWidth = UIScreen.mainScreen().bounds.size.width
            
            if let previewURL = content.previewImageURL(ofMinimumWidth: minWidth) {
                blurredImageView.applyBlurToImageURL(previewURL, withRadius: 12.0) { [weak self] in
                    self?.blurredImageView.alpha = blurredImageAlpha
                }
            }
            
            createdAtLabel.text = content.createdAt.stringDescribingTimeIntervalSinceNow(format: .concise, precision: .seconds) ?? ""
            captionLabel.text = content.text
            mediaContentView.content = content
            
            // Update size
            self.frame.size = sizeForContent(content)
        }
    }
    
    func setHeader(for content: ContentModel, author: UserModel ) {
        userNameButton.setTitle(author.name, forState: .Normal)
        
        if let pictureURL = author.previewImageURL(ofMinimumSize: profileImageView.frame.size) {
            profileImageView.sd_setImageWithURL(pictureURL, placeholderImage: placeholderImage)
        } else {
            profileImageView.image = placeholderImage
        }
        
        createdAtLabel.text = content.createdAt.stringDescribingTimeIntervalSinceNow(format: .concise, precision: .seconds) ?? ""
        captionLabel.text = content.text
    }
    
    @IBAction func selectedProfile(sender: AnyObject) {
        guard let userID = content?.author.id else {
            return
        }
        delegate?.didSelectProfileForUserID(userID)
    }
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager, delegate: CloseUpViewDelegate? = nil) -> CloseUpView {
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
        relatedLabel.alpha = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var totalHeight = headerSection.bounds.size.height + headerSection.frame.origin.y
        
        if content == nil {
            var mediaContentViewFrame = mediaContentView.frame
            mediaContentViewFrame.origin.y = totalHeight
            mediaContentViewFrame.size.height = self.frame.size.height - totalHeight
            mediaContentView.frame = mediaContentViewFrame
            return
        }
        
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
    
    func sizeForContent(content: ContentModel) -> CGSize {
        let contentHeight = height(for: content)
        
        if !contentHasText(content) {
            return CGSize(
                width: screenWidth,
                height: headerSection.bounds.size.height + contentHeight + relatedLabel.bounds.size.height
            )
        }
        
        var frame = captionLabel.frame
        frame.size.width = screenWidth - 2 * horizontalMargins
        captionLabel.frame = frame
        captionLabel.text = content.text
        captionLabel.sizeToFit()
        
        let totalHeight = headerSection.bounds.size.height +
            contentHeight +
            captionLabel.bounds.size.height +
            2 * verticalMargins +
            relatedLabel.bounds.size.height
        
        return CGSize(
            width: screenWidth,
            height: totalHeight
        )
    }
    
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
    
    // MARK: - ConfigurableGridStreamHeader
    
    func decorateHeader(dependencyManager: VDependencyManager, maxHeight: CGFloat, content: ContentModel?) {
        self.content = content
    }
    
    func sizeForHeader(dependencyManager: VDependencyManager, maxHeight: CGFloat, content: ContentModel?) -> CGSize {
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        guard let content = content else {
            return CGSizeMake(screenWidth, screenWidth)
        }
        return sizeForContent(content)
    }
    
    func headerWillAppear() {
        mediaContentView.videoCoordinator?.playVideo()
    }
    
    func headerDidDisappear() {
        mediaContentView.videoCoordinator?.pauseVideo()
    }
    
    func gridStreamDidUpdateDataSource(with items: [ContentModel]) {
        dispatch_async(dispatch_get_main_queue(), {
            UIView.animateWithDuration(CloseUpView.relatedAnimationDuration, animations: {
                self.relatedLabel.alpha = items.count == 0 ? 0 : 1
            })
        })
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
