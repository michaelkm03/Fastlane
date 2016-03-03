//
//  ComposerViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ComposerViewController: NSObject {
    
    weak var delegate: ComposerViewControllerDelegate?
    
    let attachmentTabs: [ComposerViewControllerAttachmentTab]
    
    var maximumHeight: CGFloat = CGFloat.max {
        didSet {
            //Update height if maximumHeight is now less than the current height
        }
    }
    
    init(attachmentTabs: [ComposerViewControllerAttachmentTab]) {
        self.attachmentTabs = attachmentTabs
        super.init()
    }
    
    func addTagForUser(user: VUser) {
        
    }
    
    func add(add: Bool, tagForHashtag hashtag: VHashtag) {
        
    }
}
