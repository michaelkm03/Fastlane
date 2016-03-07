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
    var maximumTextLength: Int = 0
    
    weak var delegate: ComposerViewControllerDelegate?
    
    /// The attachment tabs displayed by the composer. Updating this variable
    /// triggers a UI update. Defaults to nil.
    var attachmentTabs: [ComposerViewControllerAttachmentTab]? {
        didSet {
            //Update tabs displayed in the composer
        }
    }
    
    /// The maximum height of the composer. Triggers a UI update if the composer
    /// could be updated to better represent its content inside a frame with the new height.
    var maximumHeight: CGFloat = CGFloat.max {
        didSet {
            //Update height if maximumHeight is now less than the current height
        }
    }
}
