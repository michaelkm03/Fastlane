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
    
    private var iconImageView: UIImageView!
    private var overlayImageView: UIImageView!
    
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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    func sharedInit() {
        self.overlayImageView = UIImageView()
        self.overlayImageView.contentMode = UIViewContentMode.ScaleAspectFit;
        self.addSubview(self.overlayImageView)
        self.v_addFitToParentConstraintsToSubview(self.overlayImageView)
        
        self.iconImageView = UIImageView()
        self.iconImageView.contentMode = UIViewContentMode.ScaleAspectFit;
        self.addSubview(self.iconImageView)
        self.v_addFitToParentConstraintsToSubview(self.iconImageView)
    }
}
