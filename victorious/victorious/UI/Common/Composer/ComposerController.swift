//
//  ComposerController.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ComposerController: NSObject {
    
    let attachmentTabs: [ComposerControllerAttachmentTab]
    
    var maximumHeight: CGFloat = CGFloat.max {
        didSet {
            //Update height if maximumHeight is now less than the current height
        }
    }
    
    init(attachmentTabs: [ComposerControllerAttachmentTab]) {
        self.attachmentTabs = attachmentTabs
        super.init()
    }
}
