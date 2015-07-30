//
//  ExperienceEnhancerIconView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// A emotive ballistic view responsible for showing
/// a border image and an icon image
class ExperienceEnhancerIconView : UIView {
    
    private let iconImageView = UIImageView()
    private let overlayImageView = UIImageView(image: UIImage(named: "ballistic_background_icon"))
    
    var iconImage : UIImage? {
        didSet {
            self.iconImageView.image = iconImage;
        }
    }
    
    var overlayImage : UIImage? {
        didSet {
            self.overlayImageView.image = overlayImage;
        }
    }
    
    var iconURL : NSURL? {
        didSet {
            self.iconImageView.sd_setImageWithURL(iconURL)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
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
}
