//
//  ContentPreviewView.swift
//  victorious
//
//  Created by Vincent Ho on 5/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ContentPreviewView: UIView {
    // Change to actual assets
    private let kPlayButtonPlayImageName = "directory_play_btn"
    private let playButtonSize: CGFloat = 30
    private let vipMargins: CGFloat = 6
    
    let previewImageView = UIImageView()
    let vipImageView: UIView
    let playButton: UIView
    
    init() {
        
        /// Play Button
        playButton = UIImageView(image: UIImage(named: kPlayButtonPlayImageName))
        playButton.contentMode = UIViewContentMode.ScaleAspectFill
        
        /// VIP icon
        let label = UILabel()
        label.text = "VIP"
        label.textColor = .whiteColor()
        vipImageView = label
        
        super.init(frame: CGRectZero)
        backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        previewImageView.backgroundColor = .clearColor()
        
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
        playButton.v_addWidthConstraint(playButtonSize)
        playButton.v_addHeightConstraint(playButtonSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var content: ContentModel? {
        didSet {
            guard let content = content else {
                assertionFailure("Content cannot be nil")
                return
            }
            setupForContent(content)
        }
    }
    
    private func setupForContent(content: ContentModel) {
        print(frame)
        guard let previewImageURL = content.largestPreviewImageURL else {
                return
        }
        
        let userIsVIP = VCurrentUser.user()?.isVIPValid() ?? false
        let contentIsForVIPOnly = content.isVIPOnly
        if !userIsVIP && contentIsForVIPOnly {
            vipImageView.hidden = false
            previewImageView.applyBlurToImageURL(previewImageURL, withRadius: 6.0) { [weak self] in
                self?.previewImageView.alpha = 1
            }
        } else {
            vipImageView.hidden = true
            previewImageView.sd_setImageWithURL(previewImageURL)
        }
        
        switch content.type {
        case .video:
            playButton.hidden = false
        case .text, .gif, .image:
            playButton.hidden = true
        }
    }
}
