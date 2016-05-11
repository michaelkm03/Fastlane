//
//  ContentPreviewView.swift
//  victorious
//
//  Created by Vincent Ho on 5/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ContentPreviewView: UIView {
    var previewImageView: UIImageView = UIImageView()
    
    override func awakeFromNib() {
        backgroundColor = .clearColor()
        previewImageView.contentMode = UIViewContentMode.ScaleAspectFill
        addSubview(previewImageView)
        v_addFitToParentConstraintsToSubview(previewImageView)
    }
    
    var content: VContent? {
        didSet {
            guard let content = content else {
                fatalError("Content cannot be nil")
            }
            if let preview = content.largestPreviewAsset(),
                let previewRemoteURL = preview.imageURL,
                let previewImageURL = NSURL(string: previewRemoteURL) {
                previewImageView.sd_setImageWithURL(previewImageURL)
            }
            setupForContent(content)
        }
    }
    
    private func setupForContent(content: VContent) {
        // VIP blur, lock
        // Video play button
        
        guard let contentType = content.contentType() else {
            // default to image type
            previewImageView.hidden = false
            return
        }
        switch contentType {
        case .image:
            previewImageView.hidden = false
        case .video:
            previewImageView.hidden = false
        case .gif:
            previewImageView.hidden = false
        }
    }
}