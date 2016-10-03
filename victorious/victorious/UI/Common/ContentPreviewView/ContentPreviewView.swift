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
        
        static let gradientStartColor = UIColor(red: 76/255, green: 76/255, blue: 76/255, alpha: 0.5)
        static let gradientEndColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
    }

    private let previewImageView = UIImageView()
    private let gradientView = VLinearGradientView()
    private var vipButton: UIButton?
    
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
                setupOrCreateVIPButton()
            }
        }
    }
    
    private func setupOrCreateVIPButton() {
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
        playButton.contentMode = UIViewContentMode.ScaleAspectFill
        playButton.alpha = 0
        
        super.init(frame: CGRectZero)
        
        let colors = [
            Constants.gradientStartColor,
            Constants.gradientEndColor
        ]
        gradientView.setColors(colors)
        gradientView.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientView.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        backgroundColor = Constants.loadingColor
        previewImageView.backgroundColor = .clearColor()
        
        /// Preview Image View
        previewImageView.contentMode = .ScaleAspectFill
        addSubview(previewImageView)
        
        addSubview(playButton)
        
        addSubview(gradientView)
        
        if let spinner = spinner {
            addSubview(spinner)
            sendSubviewToBack(spinner)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userVIPStatusChanged), name: VCurrentUser.userDidUpdateNotificationKey, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        previewImageView.frame = self.bounds
        gradientView.frame = self.bounds
        
        playButton.frame = CGRect(
            origin: CGPoint(x: bounds.center.x - Constants.playButtonSize.width/2, y: bounds.center.y - Constants.playButtonSize.height/2),
            size: Constants.playButtonSize
        )
        
        if let vipButton = vipButton {
            vipButton.frame = CGRect(
                origin: CGPoint(
                    x: bounds.center.x - vipButton.intrinsicContentSize().width/2,
                    y: bounds.size.height - Constants.vipSize.height - Constants.vipMargins
                ),
                size: vipButton.intrinsicContentSize()
            )
        }
        
        if let content = content where lastSize.area / bounds.size.area < Constants.imageReloadThreshold {
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
    
    private func setupForContent(content: Content) {
        spinner?.startAnimating()
        let userCanViewContent = VCurrentUser.user?.canView(content) == true
        gradientView.hidden = userCanViewContent
        vipButton?.hidden = userCanViewContent
        
        setupImage(forContent: content)
        
        switch content.type {
            case .video: playButton.hidden = false
            case .text, .link, .gif, .image, .sticker: playButton.hidden = true
        }
    }
    
    private func setupImage(forContent content: Content) {
        if let imageAsset = content.previewImage(ofMinimumWidth: bounds.size.width) {
            previewImageView.getImageAsset(imageAsset) { [weak self] result in
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
    
    private func finishedLoadingPreviewImage(image: UIImage?, for content: Content) {
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
    
    private dynamic func userVIPStatusChanged() {
        guard let currentContent = content else {
            return
        }
        setupForContent(currentContent)
    }
}

private extension VDependencyManager {
    var userIsVIPButton: UIButton? {
        return buttonForKey("button.vip")
    }
}
