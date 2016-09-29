//
//  ContentPreviewView.swift
//  victorious
//
//  Created by Vincent Ho on 5/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ContentPreviewView: UIView {
    fileprivate struct Constants {
        // Change to actual assets
        static let playButtonPlayImageName = "directory_play_btn"
        static let playButtonSize = CGSize(width: 30, height: 30)
        
        static let loadingColor = UIColor.white.withAlphaComponent(0.2)
        static let imageViewBlurEffectRadius: CGFloat = 12.0
        
        static let vipMargins: CGFloat = 6
        static let vipSize = CGSize(width: 30, height: 30)
        
        static let imageReloadThreshold = CGFloat(0.75)
    }

    fileprivate let previewImageView = UIImageView()
    fileprivate var vipButton: UIButton?
    
    fileprivate let playButton: UIView
    
    fileprivate let loadingSpinnerEnabled: Bool
    fileprivate lazy var spinner: UIActivityIndicatorView? = {
        return self.loadingSpinnerEnabled ? UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge) : nil
    }()
    
    fileprivate var lastSize = CGSize.zero
    
    var dependencyManager: VDependencyManager? {
        didSet {
            if
                let dependencyManager = dependencyManager
                , dependencyManager != oldValue
            {
                setupOrCreateVIPButton()
            }
        }
    }
    
    fileprivate func setupOrCreateVIPButton() {
        vipButton?.removeFromSuperview()
        vipButton = self.dependencyManager?.userIsVIPButton
        
        if let vipButton = vipButton {
            addSubview(vipButton)
        }
    }
    
    // MARK: - Initialization
    
    init(loadingSpinnerEnabled: Bool = false) {
        self.loadingSpinnerEnabled = loadingSpinnerEnabled
        
        // Play Button
        playButton = UIImageView(image: UIImage(named: Constants.playButtonPlayImageName))
        playButton.contentMode = UIViewContentMode.scaleAspectFill
        playButton.alpha = 0
        
        super.init(frame: CGRect.zero)
        
        backgroundColor = Constants.loadingColor
        previewImageView.backgroundColor = .clear()
        
        /// Preview Image View
        previewImageView.contentMode = .scaleAspectFill
        addSubview(previewImageView)
        
        addSubview(playButton)
        
        if let spinner = spinner {
            addSubview(spinner)
            sendSubview(toBack: spinner)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(userVIPStatusChanged), name: NSNotification.Name(rawValue: VCurrentUser.userDidUpdateNotificationKey), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        previewImageView.frame = self.bounds
        
        playButton.frame = CGRect(
            origin: CGPoint(x: bounds.center.x - Constants.playButtonSize.width/2, y: bounds.center.y - Constants.playButtonSize.height/2),
            size: Constants.playButtonSize
        )
        
        if let vipButton = vipButton {
            vipButton.frame = CGRect(
                origin: CGPoint(x: Constants.vipMargins, y: bounds.size.height - Constants.vipSize.height - Constants.vipMargins),
                size: vipButton.intrinsicContentSize
            )
        }
        
        if let content = content , lastSize.area / bounds.size.area < Constants.imageReloadThreshold {
            setupImage(forContent: content)
        }
        
        spinner?.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    // MARK: - Content Setup
    
    var content: Content? {
        didSet {
            guard let content = content else {
                assertionFailure("Content cannot be nil in ContentPreviewView.")
                return
            }
            setupForContent(content)
        }
    }
    
    fileprivate func setupForContent(_ content: Content) {
        spinner?.startAnimating()
        vipButton?.hidden = !content.isVIPOnly
        
        setupImage(forContent: content)
        
        switch content.type {
            case .video: playButton.isHidden = false
            case .text, .link, .gif, .image: playButton.isHidden = true
        }
    }
    
    fileprivate func setupImage(forContent content: Content) {
        let userCanViewContent = VCurrentUser.user?.canView(content) == true
        if let imageAsset = content.previewImage(ofMinimumWidth: bounds.size.width) {
            let blurRadius = userCanViewContent ? 0 : Constants.imageViewBlurEffectRadius
            previewImageView.getImageAsset(imageAsset, blurRadius: blurRadius) { [weak self] result in
                switch result {
                    case .success(let image):
                        self?.finishedLoadingPreviewImage(image, for: content)
                        
                    case .failure(_):
                        self?.finishedLoadingPreviewImage(nil, for: content)
                }
            }
        }
        else {
            previewImageView.image = nil
        }
        lastSize = bounds.size
    }
    
    fileprivate func finishedLoadingPreviewImage(_ image: UIImage?, for content: Content) {
        let contentID = self.content?.id
        guard content.id == contentID || contentID == nil else {
            return
        }
        
        self.previewImageView.image = image
        self.previewImageView.alpha = 1
        self.playButton.alpha = 1
        self.spinner?.stopAnimating()
    }
    
    // MARK: - Notification actions
    
    fileprivate dynamic func userVIPStatusChanged() {
        guard let currentContent = content else {
            return
        }
        setupForContent(currentContent)
    }
}

private extension VDependencyManager {
    var userIsVIPButton: UIButton? {
        return button(forKey: "button.vip")
    }
}
