//
//  NewItemsController.swift
//  victorious
//
//  Created by Patrick Lynch on 2/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

@objc protocol NewItemsControllerDelegate {
    func onNewItemsSelected()
}

class NewItemsController: NSObject {
    
    let largeNumberFormatter = VLargeNumberFormatter()
    
    var depedencyManager: VDependencyManager! {
        didSet {
            button.backgroundColor = depedencyManager.backgroundColor
            button.titleLabel?.font = depedencyManager.font
            button.titleLabel?.textColor = depedencyManager.textColor
        }
    }
    
    private(set) var isShowing: Bool = true
    
    var count: Int = 0 {
        didSet {
            let formattedMessageCount: String = largeNumberFormatter.stringForInteger(count)
            let title: String
            if count == 1 {
                title = NSString(format: NSLocalizedString("NewMessagesFormatSingular", comment:""), formattedMessageCount) as String
            } else {
                title = NSString(format: NSLocalizedString("NewMessagesFormatPlural", comment:""), formattedMessageCount) as String
            }
            UIView.setAnimationsEnabled(false)
            self.button.setTitle(title, forState: .Normal)
            UIView.setAnimationsEnabled(true)
            
            let attributes = [ NSFontAttributeName : button.titleLabel!.font ]
            buttonWidthConstraint.constant = (title as NSString).sizeWithAttributes( attributes ).width
            button.layoutIfNeeded()
        }
    }
    @IBOutlet weak var delegate: NewItemsControllerDelegate?
    
    @IBOutlet weak var buttonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var button: UIButton! {
        didSet {
            button.layer.shadowColor = UIColor.blackColor().CGColor
            button.layer.shadowRadius = 4.0
            button.layer.shadowOpacity = 1.0
            button.layer.cornerRadius = 5.0
            button.layer.shadowOffset = CGSize(width:0, height:2)
        }
    }
    
    private var moreContentButtonToBottomStoryboardValue: CGFloat?
    @IBOutlet private weak var buttonToBottomConstraint: NSLayoutConstraint! {
        didSet {
            moreContentButtonToBottomStoryboardValue = buttonToBottomConstraint.constant
        }
    }
    
    func show(animated animated: Bool = true) {
        guard !isShowing else {
            return
        }
        isShowing = true
        let animations = {
            guard let bottomConstant = self.moreContentButtonToBottomStoryboardValue else {
                assertionFailure("moreContentButtonToBottomStoryboardValue must be set as soon as this class is instantiated from a storyboard.")
                return
            }
            self.buttonToBottomConstraint.constant = bottomConstant
            self.button.alpha = 1.0
            self.button.layoutIfNeeded()
        }
        if animated {
            UIView.animateWithDuration(0.4,
                delay: 0.0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.5,
                options: [],
                animations: animations,
                completion: nil
            )
        } else {
            animations()
        }
    }
    
    func hide(animated animated: Bool = true) {
        guard isShowing else {
            return
        }
        let animations = {
            self.buttonToBottomConstraint.constant = self.button.bounds.height
            self.button.layoutIfNeeded()
            self.button.alpha = 0.0
        }
        let completion = { (_:Bool) in
            self.count = 0
            self.isShowing = false
        }
        if animated {
            UIView.animateWithDuration(0.2,
                delay: 0.0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 0.0,
                options: [],
                animations: animations,
                completion: completion
            )
        } else {
            animations()
            completion(true)
        }
    }
    
    @IBAction private func onNewItemsSelected() {
        delegate?.onNewItemsSelected()
        hide()
    }
}

private extension VDependencyManager {
    
    var textColor: UIColor {
        return colorForKey("color.text")
    }
    
    var font: UIFont {
        return fontForKey("font.text")
    }
    
    var backgroundColor: UIColor {
        return colorForKey("color.background")
    }
}
