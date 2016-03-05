//
//  ComposerViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ComposerViewController: UIViewController {
    
    /// The maximum number of characters a user can input into
    /// the composer. Defaults to 0, allowing users to input as
    /// much text as they like.
    var maximumTextLength = 0
    
    weak var delegate: ComposerViewControllerDelegate?
    
    var attachmentTabs: [ComposerViewControllerAttachmentTab]? {
        didSet {
            //Update tabs displayed in the composer
        }
    }
    
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
