//
//  ExperienceEnhancerIconView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import SDWebImage
import UIKit

/// A emotive ballistic view responsible for showing
/// a border image and an icon image
class ExperienceEnhancerIconView: UIView {
    
    private let iconImageView = UIImageView()
    private let overlayImageView = UIImageView(image: UIImage(named: "ballistic_background_icon"))
    
    var iconImage: UIImage? {
        didSet {
            self.iconImageView.image = iconImage
        }
    }
    
    var overlayImage: UIImage? {
        didSet {
            self.overlayImageView.image = overlayImage
        }
    }
    
    var iconURL: NSURL? {
        didSet {
            self.alpha = 0
            self.iconImageView.sd_setImageWithURL(iconURL, completed: {
                (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) in
                
                if (error != nil) {
                    return
                }
                
                self.setTintedIcon(image)
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.alpha = 1
                })
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    func sharedInit() {
        self.overlayImageView.contentMode = UIViewContentMode.ScaleAspectFit;
        self.addSubview(self.overlayImageView)
        self.v_addFitToParentConstraintsToSubview(self.overlayImageView)
        
        self.iconImageView.contentMode = UIViewContentMode.ScaleAspectFit;
        self.addSubview(self.iconImageView)
        self.v_addFitToParentConstraintsToSubview(self.iconImageView)
    }
    
    func setTintedIcon(image: UIImage) {
        self.iconImageView.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.overlayImageView.image = self.overlayImageView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    }
}
