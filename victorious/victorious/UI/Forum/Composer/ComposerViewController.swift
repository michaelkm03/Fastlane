//
//  ComposerViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ComposerViewController: UIViewController, Composer, ComposerTextViewManagerDelegate {
    
    @IBOutlet var inputViewToBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var textViewHeightConstraint: NSLayoutConstraint!
    
    /// Referenced so that it can be set toggled between 0 and it's default
    /// height when shouldShowAttachmentContainer is true
    @IBOutlet var attachmentContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var textView: VPlaceholderTextView!
    
    @IBOutlet var attachmentContainerView: UIView!
    
    @IBOutlet var interactiveContainerView: UIView!
    
    private var composerTextViewManager: ComposerTextViewManager?
    
    private var keyboardManager: VKeyboardNotificationManager?
    
    /// The maximum number of characters a user can input into
    /// the composer. Defaults to 0, allowing users to input as
    /// much text as they like.
    private var maximumTextLength = DefaultPropertyValues.maximumTextLength {
        didSet {
            composerTextViewManager?.maximumTextLength = maximumTextLength
        }
    }
    
    /// The attachment tabs displayed by the composer. Updating this variable
    /// triggers a UI update. Defaults to nil.
    private var attachmentTabs = DefaultPropertyValues.attachmentTabs
    
    private var shouldShowAttachmentContainer: Bool {
        return attachmentTabs != nil || textViewHasText
    }
    
    weak var delegate: ComposerDelegate?
    
    var dependencyManager: VDependencyManager! {
        didSet {
            maximumTextLength = dependencyManager.maximumTextLength()
            attachmentTabs = dependencyManager.attachmentTabs()
        }
    }
    
    
    //MARK: - ComposerController
    
    var maximumTextInputHeight = DefaultPropertyValues.maximumTextInputHeight
    
    
    //MARK: - ComposerTextViewManagerDelegate
    
    var textViewHasText: Bool = false {
        didSet {
            if oldValue != textViewHasText {
                view.setNeedsUpdateConstraints()
            }
        }
    }
    
    var textViewContentSize: CGSize = CGSize.zero {
        didSet {
            if oldValue != textViewContentSize {
                view.setNeedsUpdateConstraints()
            }
        }
    }
    
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let updateHeightBlock: VKeyboardManagerKeyboardChangeBlock = { [weak self] startFrame, endFrame, animationDuration, animationCurve in
            
            guard let strongSelf = self else {
                return
            }
            
            //TODO: Fix options
            strongSelf.inputViewToBottomConstraint.constant = strongSelf.view.bounds.height - endFrame.origin.y
            UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                strongSelf.view.layoutIfNeeded()
            }, completion: nil)
        }
        keyboardManager = VKeyboardNotificationManager(keyboardWillShowBlock: updateHeightBlock, willHideBlock: updateHeightBlock, willChangeFrameBlock: updateHeightBlock)
        
        composerTextViewManager = ComposerTextViewManager(maximumTextLength: maximumTextLength, textView: textView, delegate: self)
        
        setupTextView()
    }
    
    override func updateViewConstraints() {

        let desiredAttachmentContainerHeight = self.shouldShowAttachmentContainer ? DefaultPropertyValues.attachmentContainerHeight : 0
        if self.attachmentContainerHeightConstraint.constant != desiredAttachmentContainerHeight {
            self.attachmentContainerHeightConstraint.constant = desiredAttachmentContainerHeight
        }
        
        let desiredTextViewHeight = self.textViewHasText ? ceil(min(self.textView.contentSize.height, self.maximumTextInputHeight)) : 40
        if self.textViewHeightConstraint.constant != desiredTextViewHeight {
            self.textViewHeightConstraint.constant = desiredTextViewHeight
        }
        
        UIView.animateWithDuration(0.3, delay: 0, options: .AllowUserInteraction, animations: {
            self.textView.layoutIfNeeded()
            self.attachmentContainerView.layoutIfNeeded()
            self.interactiveContainerView.layoutIfNeeded()
        }, completion: nil)
        
        super.updateViewConstraints()
    }
    
    private func setupTextView() {
        textView.text = nil
        textView.placeholderText = "Join the conversation"
    }
}

private struct DefaultPropertyValues {
    
    static let maximumTextInputHeight = CGFloat.max
    static let maximumTextLength = 0
    static let attachmentTabs: [ComposerAttachmentTab]? = nil
    static let attachmentContainerHeight: CGFloat = 52
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
