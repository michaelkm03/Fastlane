//
//  ComposerViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ComposerViewController: UIViewController, Composer {
    
    /// The maximum number of characters a user can input into
    /// the composer. Defaults to 0, allowing users to input as
    /// much text as they like.
    private let maximumTextLength: Int = 0
    
    /// The attachment tabs displayed by the composer. Updating this variable
    /// triggers a UI update. Defaults to nil.
    private let attachmentTabs: [ComposerAttachmentTab]? = nil
    
    
    //MARK: - ComposerController
    
    var maximumHeight: CGFloat = CGFloat.max {
        didSet {
            //Update height if maximumHeight is now less than the current height
        }
    }
    
    weak var delegate: ComposerDelegate?
    
    
    //MARK: Initialization
    
    var dependencyManager: VDependencyManager! {
        didSet {
            
        }
    }
}
