//
//  VIPBadgeView.swift
//  victorious
//
//  Created by Vincent Ho on 6/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class VIPBadgeView: UIView {
    var dependencyManager: VDependencyManager? {
        didSet {
            guard let dependencyManager = dependencyManager else {
                return
            }
            badgeOutline.tintColor = dependencyManager.tintColor
        }
    }
    
    @IBOutlet weak var badgeOutline: UIImageView!
    @IBOutlet weak var badgeText: UIImageView!
    
    class func newVIPBadgeView() -> VIPBadgeView {
        let view: VIPBadgeView = VIPBadgeView.v_fromNib()
        return view
    }
    
    override func awakeFromNib() {
        let image = badgeOutline.image
        badgeOutline.image = image?.imageWithRenderingMode(.AlwaysTemplate)
    }
}

private extension VDependencyManager {
    var tintColor: UIColor {
        return .blueColor()
    }
}
