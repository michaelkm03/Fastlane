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
                assertionFailure("Content cannot be nil")
                return
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
        
        previewImageView.hidden = false
    }
    
    class func reuseIdentifier() -> String {
        return NSStringFromClass(ContentPreviewView.self)
    }
}