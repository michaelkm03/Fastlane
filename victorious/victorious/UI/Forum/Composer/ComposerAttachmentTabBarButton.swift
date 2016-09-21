//
//  ComposerAttachmentTabBarButton.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ComposerAttachmentTabBarButton: UIButton {
    let navigationMenuItem: VNavigationMenuItem
    
    init(navigationMenuItem: VNavigationMenuItem, frame: CGRect = CGRect.zero) {
        self.navigationMenuItem = navigationMenuItem
        super.init(frame: frame)
        adjustsImageWhenDisabled = true
        setImage(navigationMenuItem.icon, forState: .Normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
