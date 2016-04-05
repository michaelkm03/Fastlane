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
class MediaAttachmentImageView : MediaAttachmentView {
    
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
        
        self.backgroundColor = UIColor.blackColor()
        
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        self.mediaButton.addTarget(self, action: #selector(mediaButtonPressed), forControlEvents: .TouchUpInside)
        
        self.addSubview(imageView)
        self.addSubview(mediaButton)
        
        self.v_addFitToParentConstraintsToSubview(imageView)
        self.v_addFitToParentConstraintsToSubview(mediaButton)
    }
    
    override var comment: VComment? {
        didSet {
            if let unwrapped = comment {
                self.previewImageURL = unwrapped.previewImageURL()
            }
        }
    }
    
    override var message: VMessage? {
        didSet {
            if let unwrapped = message {
                self.previewImageURL = unwrapped.previewImageURL()
            }
        }
    }
    
    var previewImageURL: NSURL? {
        didSet {
            if let previewURL = previewImageURL {
                // Check if we're setting the same image
                if (previewURL.isEqual(oldValue)) {
                    return
                }
                self.imageView.alpha = 0
                self.imageView.sd_setImageWithURL(previewURL, completed: {
                    (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
                    
                    if (error != nil)
                    {
                        return;
                    }
                    
                    self.imageView.image = image
                    
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        self.imageView.alpha = 1
                    })
                })
            }
        }
    }
    
    func mediaButtonPressed() {
        if let completion = self.respondToButton {
            completion(previewImage: self.imageView.image)
        }
    }
}
