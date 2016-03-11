//
//  ComposerViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ComposerViewController: UIViewController, Composer {
    
    @IBOutlet var inputViewToBottomConstraint: NSLayoutConstraint!
    
    private var keyboardManager: VKeyboardNotificationManager!
    
    /// The maximum number of characters a user can input into
    /// the composer. Defaults to 0, allowing users to input as
    /// much text as they like.
    private var maximumTextLength = DefaultPropertyValues.maximumTextLength
    
    /// The attachment tabs displayed by the composer. Updating this variable
    /// triggers a UI update. Defaults to nil.
    private var attachmentTabs = DefaultPropertyValues.attachmentTabs
    
    
    //MARK: - ComposerController
    
    var maximumTextInputHeight = DefaultPropertyValues.maximumTextInputHeight {
        didSet {
            
        }
    }
    
    weak var delegate: ComposerDelegate?
    
    
    //MARK: Initialization
    
    private var dependencyManager: VDependencyManager! {
        didSet {
            maximumTextLength = dependencyManager.maximumTextLength()
            attachmentTabs = dependencyManager.attachmentTabs()
        }
    }
    
    class func newWithDependencyManager( dependencyManager: VDependencyManager ) -> ComposerViewController {
        
        let composerVC = UIStoryboard.init(name: "ComposerViewController", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as! ComposerViewController
        composerVC.dependencyManager = dependencyManager
        let updateHeightBlock: VKeyboardManagerKeyboardChangeBlock = { startFrame, endFrame, animationDuration, animationCurve in
            
            //TODO: Fix options
            UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                composerVC.inputViewToBottomConstraint.constant = endFrame.height
            }, completion: nil)
        }
        composerVC.keyboardManager = VKeyboardNotificationManager(keyboardWillShowBlock: updateHeightBlock, willHideBlock: updateHeightBlock, willChangeFrameBlock: updateHeightBlock)
        return composerVC
    }
}

private struct DefaultPropertyValues {
    
    static let maximumTextInputHeight = CGFloat.max
    static let maximumTextLength = 0
    static let attachmentTabs: [ComposerAttachmentTab]? = nil
}

//TODO: Update this extension to parse real values once they're returned in template
private extension VDependencyManager {
    
    func maximumTextLength() -> Int {
        return DefaultPropertyValues.maximumTextLength
    }
    
    func attachmentTabs() -> [ComposerAttachmentTab]? {
        return DefaultPropertyValues.attachmentTabs
    }
}
