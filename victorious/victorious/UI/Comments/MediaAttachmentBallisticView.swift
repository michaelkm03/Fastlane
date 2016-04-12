//
//  MediaAttachmentBallisticView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/31/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousCommon

// A media attachment view used for showing emotive ballistics inline
class MediaAttachmentBallisticView: MediaAttachmentView {
    
    let ballisticView = ExperienceEnhancerIconView(frame: CGRectZero)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    private func sharedInit() {
        self.ballisticView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.ballisticView)
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[ballisticView(50)]", options: [], metrics: nil, views: ["ballisticView": self.ballisticView])
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[ballisticView(50)]", options: [], metrics: nil, views: ["ballisticView": self.ballisticView])
        self.addConstraints(vConstraints)
        self.addConstraints(hConstraints)
    }
    
    override var comment: VComment? {
        didSet {
            if let iconURL = comment?.properMediaURLGivenContentType() {
                if let cachedImageData = VDataCache().cachedDataForID(iconURL) {
                    self.ballisticView.setTintedIcon(UIImage(data: cachedImageData)!)
                } else {
                    self.ballisticView.iconURL = iconURL
                }
            }
        }
    }
    
    override var dependencyManager: VDependencyManager? {
        didSet {
            if let unwrappedDependencyManager = dependencyManager {
                self.ballisticView.tintColor = unwrappedDependencyManager.colorForKey(VDependencyManagerAccentColorKey)
            }
        }
    }
}
