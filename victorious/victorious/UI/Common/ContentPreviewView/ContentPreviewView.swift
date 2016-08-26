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
        static let imageViewBlurEffectRadius: CGFloat = 12.0
        
        static let vipMargins: CGFloat = 6
        static let vipSize = CGSize(width: 30, height: 30)
        
        static let imageReloadThreshold = CGFloat(0.75)
    }

    private let previewImageView = UIImageView()
    private let vipIcon = UIImageView()
    private let playButton: UIView
    
    private let loadingSpinnerEnabled: Bool
    private lazy var spinner: UIActivityIndicatorView? = {
        return self.loadingSpinnerEnabled ? UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge) : nil
    }()
    
    private var lastSize = CGSizeZero
    
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
    
    // MARK: - Initialization
    
    init(loadingSpinnerEnabled: Bool = false) {
        self.loadingSpinnerEnabled = loadingSpinnerEnabled
        
        // Play Button
        playButton = UIImageView(image: UIImage(named: Constants.playButtonPlayImageName))
        playButton.contentMode = UIViewContentMode.ScaleAspectFill
        playButton.alpha = 0
        
        super.init(frame: CGRectZero)
        
        backgroundColor = Constants.loadingColor
        previewImageView.backgroundColor = .clearColor()
        
        /// Preview Image View
        previewImageView.contentMode = .ScaleAspectFill
        addSubview(previewImageView)
        
        addSubview(vipIcon)
        vipIcon.contentMode = .ScaleAspectFit
        addSubview(playButton)
        
        if let spinner = spinner {
            addSubview(spinner)
            sendSubviewToBack(spinner)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userVIPStatusChanged), name: VIPSubscriptionHelper.userVIPStatusChangedNotificationKey, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        spinner?.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    // MARK: - Content Setup
    
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
        spinner?.startAnimating()
        vipIcon.hidden = !content.isVIPOnly
        
        setupImage(forContent: content)
        
        switch content.type {
            case .video: playButton.hidden = false
            case .text, .link, .gif, .image: playButton.hidden = true
        }
    }
    
    private func setupImage(forContent content: ContentModel) {
        let userCanViewContent = VCurrentUser.user()?.canView(content) == true
        if let imageAsset = content.previewImage(ofMinimumWidth: bounds.size.width) {
            if !userCanViewContent {
                guard let imageAssetURL = imageAsset.url else {
                    return
                }
                
                previewImageView.applyBlurToImageURL(imageAssetURL, withRadius: Constants.imageViewBlurEffectRadius) { [weak self] image, _ in
                    self?.finishedLoadingPreviewImage(image, for: content)
                }
            }
            else {
                previewImageView.setImageAsset(imageAsset) { [weak self] image, _ in
                    self?.finishedLoadingPreviewImage(image, for: content)
                }
            }
        }
        else {
            previewImageView.image = nil
        }
        lastSize = bounds.size
    }
    
    private func finishedLoadingPreviewImage(image: UIImage?, for content: ContentModel) {
        let contentID = self.content?.id
        guard content.id == contentID || contentID == nil else {
            return
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.previewImageView.image = image
            self.previewImageView.alpha = 1
            self.playButton.alpha = 1
            self.spinner?.stopAnimating()
        }
    }
    
    // MARK: - Notification actions
    
    private dynamic func userVIPStatusChanged() {
        guard let currentContent = content else {
            return
        }
        setupForContent(currentContent)
    }
}

private extension VDependencyManager {
    var vipIcon: UIImage? {
        return imageForKey("icon.vip")
    }
}
