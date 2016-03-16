//
//  ComposerAttachmentTabBarButton.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ComposerAttachmentTabBarButton: UIButton {
    
    let composerAttachmentTab: ComposerAttachmentTab
    
    init(composerAttachmentTab: ComposerAttachmentTab) {
        self.composerAttachmentTab = composerAttachmentTab
        super.init(frame: CGRect.zero)
        setImage(composerAttachmentTab.associatedIcon(), forState: .Normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
