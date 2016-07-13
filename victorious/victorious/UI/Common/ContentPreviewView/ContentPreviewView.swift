//
//  ContentPreviewView.swift
//  victorious
//
//  Created by Vincent Ho on 5/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ContentPreviewView: UIView {
    private struct Constants {
        // Change to actual assets
        static let playButtonPlayImageName = "directory_play_btn"
        static let playButtonSize = CGSize(width: 30, height: 30)
        
        static let loadingColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        static let imageViewBlurEffectRadius: CGFloat = 6.0
        
        static let vipMargins: CGFloat = 6
        static let vipSize = CGSize(width: 30, height: 30)
        
        static let imageReloadThreshold = CGFloat(0.75)
    }

    let previewImageView = UIImageView()
    let vipIcon = UIImageView()
    let playButton: UIView
    var lastSize = CGSizeZero
    
    var dependencyManager: VDependencyManager? {
        didSet {
            if
                let dependencyManager = dependencyManager
                where dependencyManager != oldValue
            {
                vipIcon.image = dependencyManager.vipIcon
            }
        }
    }
    
    override func layoutSubviews() {
        previewImageView.frame = self.bounds
        
        playButton.frame = CGRect(
            origin: CGPoint(x: bounds.center.x - Constants.playButtonSize.width/2, y: bounds.center.y - Constants.playButtonSize.height/2),
            size: Constants.playButtonSize
        )

        vipIcon.frame = CGRect(
            origin: CGPoint(x: Constants.vipMargins, y: bounds.size.height - Constants.vipSize.height - Constants.vipMargins),
            size: Constants.vipSize
        )
        
        if let content = content where lastSize.area / bounds.size.area < Constants.imageReloadThreshold {
            setupImage(forContent: content)
        }
    }
    
    init() {
        /// Play Button
        playButton = UIImageView(image: UIImage(named: Constants.playButtonPlayImageName))
        playButton.contentMode = UIViewContentMode.ScaleAspectFill
        
        super.init(frame: CGRectZero)
        backgroundColor = Constants.loadingColor
        previewImageView.backgroundColor = .clearColor()
        
        /// Preview Image View
        previewImageView.contentMode = .ScaleAspectFill
        addSubview(previewImageView)
        
        addSubview(vipIcon)
        vipIcon.contentMode = .ScaleAspectFit
        addSubview(playButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var content: ContentModel? {
        didSet {
            guard let content = content else {
                assertionFailure("Content cannot be nil in ContentPreviewView.")
                return
            }
            setupForContent(content)
        }
    }
    
    private func setupForContent(content: ContentModel) {
        let userCanViewContent = VCurrentUser.user()?.canView(content) == true
        vipIcon.hidden = userCanViewContent
        
        setupImage(forContent: content)
        
        switch content.type {
            case .video: playButton.hidden = false
            case .text, .link, .gif, .image: playButton.hidden = true
        }
    }
    
    private func setupImage(forContent content: ContentModel) {
        let userCanViewContent = VCurrentUser.user()?.canView(content) == true
        if let previewImageURL = content.previewImageURL(ofMinimumWidth: bounds.size.width) {
            if !userCanViewContent {
                previewImageView.applyBlurToImageURL(previewImageURL, withRadius: Constants.imageViewBlurEffectRadius) { [weak self] in
                    self?.previewImageView.alpha = 1
                }
            }
            else {
                previewImageView.sd_setImageWithURL(previewImageURL)
            }
        }
        else {
            previewImageView.image = nil
        }
        lastSize = bounds.size

    }
}

private extension VDependencyManager {
    var vipIcon: UIImage? {
        return imageForKey("icon.vip")
    }
}
