//
//  ComposerViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ComposerViewController: UIViewController {
    
    weak var delegate: ComposerViewControllerDelegate?
    
    var attachmentTabs: [ComposerViewControllerAttachmentTab]?
    
    var maximumHeight: CGFloat = CGFloat.max {
        didSet {
            //Update height if maximumHeight is now less than the current height
        }
    }
    
    func addTagForUser(user: VUser) {
        
    }
    
    func add(add: Bool, tagForHashtag hashtag: VHashtag) {
        
    }
}
