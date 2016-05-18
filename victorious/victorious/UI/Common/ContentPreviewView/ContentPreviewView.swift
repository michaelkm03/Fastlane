//
//  ContentPreviewView.swift
//  victorious
//
//  Created by Vincent Ho on 5/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ContentPreviewView: UIView {
    // TODO: Change to actual assets
    private let kPlayButtonPlayImageName = "directory_play_btn"
    private let playButtonSize: CGFloat = 30
    private let vipMargins: CGFloat = 6
    
    let previewImageView = UIImageView()
    let vipImageView: UIView
    let playButton: UIView
    
    init() {
        
        /// Play Button
        playButton = UIImageView(image: UIImage.init(named: kPlayButtonPlayImageName))
        
        /// VIP icon
        let label = UILabel()
        label.text = "VIP"
        label.textColor = .whiteColor()
        vipImageView = label
        
        super.init(frame: CGRectZero)
        backgroundColor = .clearColor()
        
        /// Preview Image View
        previewImageView.contentMode = UIViewContentMode.ScaleAspectFill
        addSubview(previewImageView)
        v_addFitToParentConstraintsToSubview(previewImageView)
        
        addSubview(vipImageView)
        v_addPinToLeadingEdgeToSubview(
            vipImageView,
            leadingMargin: vipMargins)
        v_addPinToBottomToSubview(
            vipImageView,
            bottomMargin: vipMargins)
        
        addSubview(playButton)
        v_addCenterToParentContraintsToSubview(playButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var content: VContent? {
        didSet {
            guard let content = content else {
                assertionFailure("Content cannot be nil")
                return
            }
            setupForContent(content)
        }
    }
    
    private func setupForContent(content: VContent) {
        if let preview = content.largestPreviewAsset(),
            let previewRemoteURL = preview.imageURL,
            let previewImageURL = NSURL(string: previewRemoteURL) {
            
            if content.isVIPContent() && VCurrentUser.user()?.isVIPSubscriber != 1 {
                
                vipImageView.hidden = false
                previewImageView.applyBlurToImageURL(previewImageURL, withRadius: 6.0) { [weak self] in
                    self?.previewImageView.alpha = 1
                }
            }
            else {
                vipImageView.hidden = true
                previewImageView.sd_setImageWithURL(previewImageURL)
            }
            guard let contentType = content.contentType() else {
                playButton.hidden = true
                assertionFailure("Content should have a contentType")
                return
            }
            switch contentType {
            case .video:
                playButton.hidden = false
            case .gif, .image:
                playButton.hidden = true
            }
        }
    }
    
    static func reuseIdentifier() -> String {
        return NSStringFromClass(ContentPreviewView.self)
    }
}