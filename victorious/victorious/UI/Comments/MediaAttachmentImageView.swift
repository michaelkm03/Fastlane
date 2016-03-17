//
//  MediaAttachmentImageView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/31/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import SDWebImage

// A media attachment view used for showing image previews
class MediaAttachmentImageView: MediaAttachmentView {
    
    let imageView = UIImageView()
    let mediaButton = UIButton()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    func sharedInit() {
        backgroundColor = UIColor.blackColor()
        
        addSubview(imageView)
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        
        addSubview(mediaButton)
        mediaButton.addTarget(self, action: "mediaButtonPressed", forControlEvents: .TouchUpInside)
    }
    
    override var comment: VComment? {
        didSet {
            if let comment = comment {
                _previewImageURL = comment.previewImageURL()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
        mediaButton.frame = bounds
    }
    
    override var message: VMessage? {
        didSet {
            if let message = message {
                _previewImageURL = message.previewImageURL()
            }
        }
    }
    
    private var _previewImageURL: NSURL?
    
    func setPreviewImageURL(url: NSURL) {
        guard url != _previewImageURL else {
            return
        }
        
        imageView.alpha = 0
        imageView.sd_setImageWithURL(url) { [weak self] image, error, cacheType, url in
            guard let strongSelf = self where error == nil else {
                return
            }
            strongSelf.imageView.image = image
            UIView.animateWithDuration(0.2) {
                strongSelf.imageView.alpha = 1
            }
        }
    }
    
    func mediaButtonPressed() {
        if let completion = respondToButton {
            completion(previewImage: imageView.image)
        }
    }
}
