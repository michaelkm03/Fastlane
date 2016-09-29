//
//  ComposerAttachmentTabBarButton.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// FUTURE: We should not be subclassing UIButton (http://stackoverflow.com/questions/13202161/why-shouldnt-i-subclass-a-uibutton)
class ComposerAttachmentTabBarButton: UIButton {
    let navigationMenuItem: VNavigationMenuItem
    
    init(navigationMenuItem: VNavigationMenuItem, frame: CGRect = CGRect.zero) {
        self.navigationMenuItem = navigationMenuItem
        super.init(frame: frame)
        adjustsImageWhenDisabled = true
        imageView?.contentMode = .ScaleAspectFit
        setImage(navigationMenuItem.icon, forState: .Normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
